#!/bin/bash


WORKDIR=$(pwd)
LOCALPORT=$(shuf -i 20000-65535 -n 1)

if [ ! -f rootfs.qcow2 ]; then
	echo "kdev: no rootfs found!"
	exit 1
fi

if [ "$(id -u)" != "0" ]; then
	echo "kdev: must run as root"
	exit 1
fi

set -x

qemu-system-aarch64 \
	-name "kdev-${RANDOM}" \
	-machine virt \
	-cpu max \
	-accel kvm \
	-semihosting \
	-drive file=/usr/share/AAVMF/AAVMF_CODE.fd,format=raw,if=pflash \
	-smp 4 \
	-m 4096 \
	-device virtio-scsi-pci,id=scsi \
	-drive file=rootfs.qcow2,format=qcow2,if=virtio \
	-boot order=hd \
	-serial mon:stdio \
	-net nic \
	-net user,net=192.168.122.0/24,host=192.168.122.1,hostfwd=tcp::${LOCALPORT}-:22 \
	-nographic

echo "kdev: all done!"
exit 0
