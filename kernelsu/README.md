# KernelSU artifacts

This repository is reduced to the `r12s-S721BXXSCDZF3` target.

## Published S721B artifacts

- `android14-6.1_kernelsu-r12s-S721BXXSCDZF3-kdp.ko` — target-specific KernelSU module.
- `ksud-r12s-S721BXXSCDZF3-kdp` — matching late-load userspace binary.
- `android14-6.1_kernelsu-samsung-kdp.ko` — shared Samsung KDP/RKP/DEFEX 6.1 base artifact used as build infrastructure.
- `patches/KernelSU-v3.2.5-samsung-kdp-rkp-defex.patch` — shared Samsung 6.1 KernelSU source delta.
- `tools/` — target/module auditing helpers.

The exact S721B firmware identity is defined in
`src/targets/r12s-S721BXXSCDZF3/target.h`.
