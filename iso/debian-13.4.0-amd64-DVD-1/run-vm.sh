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

qemu-system-x86_64 \
	-name "kdev-${RANDOM}" \
	-machine q35 \
	-cpu max \
	-smp 4 \
	-m 4096 \
	-device virtio-scsi-pci,id=scsi \
	-drive file=rootfs.qcow2,format=qcow2,if=virtio \
	-net nic \
	-net user,net=192.168.122.0/24,host=192.168.122.1,hostfwd=tcp::63333-:22 \
	-nographic \
	-serial mon:stdio

echo "kdev: all done!"
exit 0
