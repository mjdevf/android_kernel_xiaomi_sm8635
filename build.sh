#!/bin/bash
set -euo pipefail

# Toolchain
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

# Bersihkan (tambah -f untuk hindari prompt)
make clean || true

# Defconfig
make CC=${CROSS_COMPILE}gcc defconfig

# Manual config patch
# Tambahkan baris-baris berikut ke .config
cat >> .config << 'EOF'
# WALT + Uclamp custom configs (custom-boost)
CONFIG_SCHED_WALT=y
CONFIG_SCHED_WALT_DEBUG=m
CONFIG_SCHED_CONSERVATIVE_BOOST_LPM_BIAS=y
CONFIG_UCLAMP_TASK=y
CONFIG_UCLAMP_TASK_GROUP=y
CONFIG_UCLAMP_BUCKETS_COUNT=20
CONFIG_CPU_IDLE_GOV_TEO=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_TCP_CONG_BBR=y
CONFIG_CRYPTO_XXHASH=y
CONFIG_BPF_JIT_ALWAYS_ON=y
CONFIG_ZRAM_DEF_COMP_ZSTD=y
EOF

# Regenerasikan defconfig
make CC=${CROSS_COMPILE}gcc olddefconfig

# Build kernel Image.gz
make -j$(nproc) CC=${CROSS_COMPILE}gcc Image.gz

# Hasil
ls -lh arch/arm64/boot/Image.gz