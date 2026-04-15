#!/bin/bash

set -x
ISOURL="https://cdimage.debian.org/cdimage/archive/12.8.0/arm64/iso-dvd/debian-12.8.0-arm64-DVD-1.iso"

WORKDIR=$(pwd)
FILE_SERVER_PORT=$(shuf -i 20000-65535 -n 1)
VMNAME="kdev-$RANDOM"
ISONAME=$(basename ${ISOURL})
JOBS=$(nproc)

apt-get install -y \
	tmux \
	qemu-system-arm \
	qemu-system-gui \
	qemu-efi-aarch64 \
	qemu-utils \
	ipxe-qemu

fileserver=$(lsof -ti :${FILE_SERVER_PORT})
if [ ! -z "${fileserver}" ]; then
	kill -9 ${fileserver}
fi

if [ -f rootfs.qcow2 ]; then
	size=$(du -s rootfs.qcow2 | awk '{print $1}')
	if [ "$size" -gt 204800 ]; then
		echo "rootfs.qcow2 already ok!"
		ls -alh rootfs.qcow2
		exit 0
	fi
	lsof rootfs.qcow2
	if [ $? -eq 0 ]; then
		echo "kdev: rootfs.qcow2 is inuse"
		exit 1
	fi
	rm -f rootfs.qcow2
	qemu-img create -f qcow2 rootfs.qcow2 500G
else
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi
echo "kdev: rootfs.qcow2 ready!"

sync

if [ ! -f "${ISONAME}" ]; then
	which aria2c
	if [ $? -eq 0 ]; then
		aria2c --max-tries=10 --retry-wait=5 ${ISOURL}
	fi
fi

if [ ! -f "${ISONAME}" ]; then
	which wget
	if [ $? -eq 0 ]; then
		wget -c ${ISOURL}
	fi
fi

if [ ! -f "${ISONAME}" ]; then
	which curl
	if [ $? -eq 0 ]; then
		curl -o ${ISONAME} ${ISOURL}
	fi
fi

if [ ! -f "${ISONAME}" ]; then
	echo "kdev: cound't download ${ISONAME}"
	exit 1
fi

ls -alh ${ISONAME}
echo "kdev: ${ISONAME} ready!"

python3 -m http.server ${FILE_SERVER_PORT} --directory $(pwd) &
echo "kdev: http server ready!"
sleep 3

cleanup() {
	fileserver=$(lsof -ti :${FILE_SERVER_PORT})
	if [ ! -z "${fileserver}" ]; then
		kill -9 ${fileserver}
	fi
	umount -l mnt
	rmdir mnt
}
trap cleanup EXIT

mkdir -p mnt
mount ${ISONAME} mnt
if [ $? -ne 0 ]; then
	echo "kdev: mount ${ISONAME} failed!"
	exit 1
fi

ls -alh mnt/install.a64
if [ $? -ne 0 ]; then
	echo "kdev: casper does't exists in ${ISONAME}"
	exit 1
fi

if [ ! -f mnt/install.a64/vmlinuz ]; then
	echo "install.a64/vmlinuz does't exists!"
	exit 1
fi

if [ ! -f mnt/install.a64/initrd.gz ]; then
	echo "install.a64/initrd.gz does't exists!"
	exit 1
fi

ls -alh /dev/kvm

qemu-system-aarch64 \
	-name "${ISONAME%.*}" \
	-machine virt,gic-version=3 \
	-cpu max \
	-accel kvm \
	-smp ${JOBS} \
	-semihosting \
	-m 4096 \
	-drive file=/usr/share/AAVMF/AAVMF_CODE.fd,format=raw,if=pflash \
	-drive file=rootfs.qcow2,format=qcow2 \
	-drive file="${ISONAME}",format=raw,if=none,id=cdrom,media=cdrom \
	-device virtio-scsi-device \
	-device scsi-cd,drive=cdrom \
	-boot order=dc \
	-kernel mnt/install.a64/vmlinuz \
	-initrd mnt/install.a64/initrd.gz \
	-append "auto=true priority=critical preseed/url=http://10.0.2.1:${FILE_SERVER_PORT}/preseed.cfg earlyprintk console=ttyAMA0,115200n8 earlycon=pl011,mmio,0x09000000 level=10 " \
	-net user,host=10.0.2.1,hostfwd=tcp::60023-:22 \
	-net nic,model=e1000 \
	-display none \
	-serial mon:stdio \
	-nographic

sync
ls -alh rootfs.qcow2
size=$(du -s rootfs.qcow2 | awk '{print $1}')
if [ "$size" -gt 204800 ]; then
	qemu-img snapshot -c 'install os' rootfs.qcow2
	qemu-img snapshot -l rootfs.qcow2
	ls -alh rootfs.qcow2
else
	echo "kdev: rootfs.qcow2 size too small, abort!"
	exit 1
fi

echo "kdev: all done!"
exit 0
