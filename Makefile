API ?= 36
TARGET ?= r12s-S721BXXSCDZF3
OUTDIR ?= build/$(TARGET)

TARGET_HEADER := src/targets/$(TARGET)/target.h
TARGET_INCLUDE := targets/$(TARGET)/target.h

# Automatically find Android NDK if ANDROID_NDK_HOME is not set.
ifndef ANDROID_NDK_HOME
ifneq ($(wildcard /usr/local/lib/android/sdk/ndk/*),)
ANDROID_NDK_HOME := $(shell ls -d /usr/local/lib/android/sdk/ndk/* | sort -V | tail -1)
endif
endif

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
TARGET_CC := $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android$(API)-clang
else
TARGET_CC := $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android$(API)-clang
endif

ifeq ($(wildcard $(TARGET_CC)),)
$(error Android NDK compiler not found: $(TARGET_CC). Set ANDROID_NDK_HOME to a valid Android NDK.)
endif

PRELOAD := $(OUTDIR)/cve-2026-43499
APP_PRELOAD := $(OUTDIR)/cve-2026-43499-app.so
APP_RELEASE := $(OUTDIR)/cve-2026-43499-app.release.so
APP_STABLE := $(OUTDIR)/cve-2026-43499-app.stable.so
APP_RELEASE_SIZE := 104128
ROOT_HELPER := $(OUTDIR)/cve-2026-43499-root

TARGET_CFLAGS :=
APP_RELEASE_OPT := -Oz
APP_RELEASE_LINK_FLAGS := -Wl,--gc-sections -Wl,--icf=all -s

PRELOAD_SRCS := \
  src/main.c \
  src/util.c \
  src/slide.c \
  src/fops.c \
  src/pipe.c \
  src/root.c \
  src/preload.c

APP_PRELOAD_SRCS := \
  src/main.c \
  src/util.c \
  src/slide_app.c \
  src/fops.c \
  src/pipe.c \
  src/root.c \
  src/preload.c

COMMON_CFLAGS := \
  -O2 -g0 -Wall -Wextra \
  -Wno-unused-parameter -Wno-sign-compare \
  -Isrc -DTARGET_HEADER='"$(TARGET_INCLUDE)"' \
  $(TARGET_CFLAGS)

.DEFAULT_GOAL := all

.PHONY: all clean info release stable

all: $(PRELOAD) $(APP_PRELOAD) $(ROOT_HELPER)

release: $(APP_RELEASE)

stable: $(APP_STABLE)

$(OUTDIR):
	mkdir -p $@

$(PRELOAD): $(PRELOAD_SRCS) $(TARGET_HEADER) src/offset.h src/common.h src/kernelsnitch/*.h | $(OUTDIR)
	$(TARGET_CC) -fPIC $(COMMON_CFLAGS) $(PRELOAD_SRCS) \
	  -shared -pthread -o $@

$(ROOT_HELPER): src/su_daemon.c | $(OUTDIR)
	$(TARGET_CC) -fPIE -pie -O2 -g0 -Wall -Wextra $< -ldl -o $@

$(APP_PRELOAD): $(APP_PRELOAD_SRCS) $(TARGET_HEADER) src/offset.h src/common.h src/kernelsnitch/*.h | $(OUTDIR)
	$(TARGET_CC) -DAPP_PAYLOAD=1 -fPIC $(COMMON_CFLAGS) $(APP_PRELOAD_SRCS) \
	  -shared -pthread -o $@

$(APP_RELEASE): $(APP_PRELOAD_SRCS) $(TARGET_HEADER) src/offset.h src/common.h src/kernelsnitch/*.h | $(OUTDIR)
	$(TARGET_CC) -DAPP_PAYLOAD=1 -fPIC $(APP_RELEASE_OPT) -g0 \
	  -fno-unwind-tables -fno-asynchronous-unwind-tables \
	  -ffunction-sections -fdata-sections \
	  -Wall -Wextra -Wno-unused-parameter -Wno-sign-compare \
	  -Isrc -DTARGET_HEADER='"$(TARGET_INCLUDE)"' \
	  $(TARGET_CFLAGS) \
	  $(APP_PRELOAD_SRCS) -shared -pthread \
	  $(APP_RELEASE_LINK_FLAGS) -o $@
	@test $$(stat -c %s $@) -le $(APP_RELEASE_SIZE)
	truncate -s $(APP_RELEASE_SIZE) $@

$(APP_STABLE): $(APP_PRELOAD_SRCS) $(TARGET_HEADER) src/offset.h src/common.h src/kernelsnitch/*.h | $(OUTDIR)
	$(TARGET_CC) -DAPP_PAYLOAD=1 -fPIC -Oz -g0 -fvisibility=hidden -fno-semantic-interposition \
	  -fstack-protector-strong \
	  -fno-unwind-tables -fno-asynchronous-unwind-tables \
	  -ffunction-sections -fdata-sections \
	  -Wall -Wextra -Wno-unused-parameter -Wno-sign-compare \
	  -Isrc -DTARGET_HEADER='"$(TARGET_INCLUDE)"' \
	  $(APP_PRELOAD_SRCS) -shared -pthread \
	  -Wl,--gc-sections -Wl,--icf=all -s -o $@
	@test $$(stat -c %s $@) -le $(APP_RELEASE_SIZE)
	truncate -s $(APP_RELEASE_SIZE) $@

info:
	@echo "TARGET=$(TARGET)"
	@echo "ANDROID_NDK_HOME=$(ANDROID_NDK_HOME)"
	@echo "TARGET_CC=$(TARGET_CC)"
	@echo "PRELOAD=$(PRELOAD)"
	@echo "APP_PRELOAD=$(APP_PRELOAD)"
	@echo "APP_RELEASE=$(APP_RELEASE)"
	@echo "APP_STABLE=$(APP_STABLE)"
	@echo "ROOT_HELPER=$(ROOT_HELPER)"

clean:
	rm -rf $(OUTDIR)



لكن انتبه: هذا يصلح مشكلة اختيار NDK فقط. إذا كان الـworkflow فعلاً يثبت NDK 30، فالرسالة القديمة التي تشير إلى 29.0.14206865 يجب أن تختفي.


والأفضل أن يكون في الـworkflow قبل make:


- name: Set up NDK
  uses: android-actions/setup-android@v3

- name: Install NDK
  run: sdkmanager "ndk;30.0.16248370"

- name: Build
  run: |
    export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/30.0.16248370"
    make TARGET=r12s-S721BXXSCDZF3 all



إذا أرسلت لي ملف workflow الحالي كاملًا أقدر أضبط الاثنين معًا بحيث ما يبقى تعارض NDK 29/30.

