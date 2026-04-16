#!/bin/bash

ISOURL="https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04-live-server-arm64.iso"
WORKDIR=$(pwd)
FILE_SERVER_PORT=$(shuf -i 20000-65535 -n 1)
ISONAME=$(basename ${ISOURL})
JOBS=$(nproc)

if [ ! -f rootfs.qcow2 ]; then
    echo "no rootfs found!"
    exit 1
fi

qemu-system-aarch64 \
  -name "${ISONAME%.*}" \
  -machine virt \
  -cpu max \
  -accel kvm \
  -semihosting \
  -drive file=/usr/share/AAVMF/AAVMF_CODE.fd,format=raw,if=pflash \
  -smp ${JOBS} \
  -m 4096 \
  -device virtio-scsi-pci,id=scsi \
  -drive file=compressed.qcow2,format=qcow2,if=virtio \
  -cdrom ${ISONAME} \
  -boot order=hd \
  -serial mon:stdio \
  -net nic \
  -net user,net=192.168.122.0/24,host=192.168.122.1 \
  -nographic

echo "kdev: all done!"
exit 0
