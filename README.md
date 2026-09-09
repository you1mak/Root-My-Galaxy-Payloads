# Root My Galaxy Payloads — S721B only

This fork contains the native payload and KernelSU artifacts for exactly one
device profile:

| Item | Value |
| --- | --- |
| Payload | `r12s-S721BXXSCDZF3` |
| Model | `SM-S721B` (Galaxy S24 FE) |
| Firmware | `S721BXXSCDZF3` |
| Android | 16 / SDK 36 |
| Kernel | `6.1.157-android14-11` |
| ABI | `arm64-v8a` |

## Build

```sh
make TARGET=r12s-S721BXXSCDZF3 ANDROID_NDK_HOME=/path/to/android-ndk
```

Release payload:

```sh
make TARGET=r12s-S721BXXSCDZF3 ANDROID_NDK_HOME=/path/to/android-ndk release
```

Outputs:

```text
build/r12s-S721BXXSCDZF3/cve-2026-43499
build/r12s-S721BXXSCDZF3/cve-2026-43499-app.so
build/r12s-S721BXXSCDZF3/cve-2026-43499-root
```

## Published artifacts

```text
artifacts/r12s-S721BXXSCDZF3/cve-2026-43499-app.so
kernelsu/android14-6.1_kernelsu-r12s-S721BXXSCDZF3-kdp.ko
kernelsu/ksud-r12s-S721BXXSCDZF3-kdp
```

The support feeds in `support/` contain only `SM-S721B`.

Use only on devices you own or are explicitly authorized to test.
