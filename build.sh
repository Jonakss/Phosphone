#!/bin/bash
set -e

echo "--- [ ~PHOSPHOR BUILD SYSTEM ] ---"

# 1. Construir entorno hermético
echo "[*] Initializing Docker Container..."
docker build -t phosphor-builder .

# 2. Compilar Kernel (Bare Metal C)
echo "[*] Compiling Phosphor Kernel (Cortex-A9)..."
mkdir -p build
docker run --rm -v $(pwd):/app phosphor-builder bash -c " \
    arm-none-eabi-gcc -c src/kernel.c -o build/kernel.o -mcpu=cortex-a9 -ffreestanding -O2 -nostdlib && \
    arm-none-eabi-ld -T src/linker.ld build/kernel.o -o build/kernel.elf && \
    arm-none-eabi-objcopy -O binary build/kernel.elf build/kernel.bin \
"

# 3. Empaquetar para Samsung Odin
echo "[*] Packaging for RECOVERY partition..."
cd build
cp kernel.bin recovery.img
tar -H ustar -c recovery.img > phosphor_recovery.tar
md5sum -t phosphor_recovery.tar >> phosphor_recovery.tar
mv phosphor_recovery.tar phosphor_recovery.tar.md5

echo ""
echo ">>> PHOSPHOR READY <<<"
echo "Output: build/phosphor_recovery.tar.md5"
echo "Flash using Odin (AP Slot)."