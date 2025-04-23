#!/bin/bash

set -x

ISOURL="https://old-releases.ubuntu.com/releases/18.04/ubuntu-18.04.5-live-server-amd64.iso"
ISOURL="https://old-releases.ubuntu.com/releases/18.04/ubuntu-18.04.5-server-amd64.iso"
ISOURL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage/releases/bionic/release/ubuntu-18.04.6-server-amd64.iso"
FILE_SERVER_PORT="63334"
VMNAME="kdev-ubuntu18"
ISONAME=$(basename ${ISOURL})

virsh destroy ${VMNAME} || :
virsh undefine ${VMNAME} --nvram || :

if [ -f rootfs.qcow2 ]; then
	lsof rootfs.qcow2
	if [ $? -eq 0 ]; then
		echo "rootfs.qcow2 is inuse"
		exit 1
	fi
	rm -f rootfs.qcow2
	qemu-img create -f qcow2 rootfs.qcow2 500G
else
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync

if [ ! -f "${ISONAME}" ]; then
	wget -c ${ISOURL}
fi

virt-install \
	--name ${VMNAME} \
	--arch x86_64 \
	--vcpus 4 \
	--ram 2048 \
	--boot cdrom,hd \
	--network network=default,model=e1000e \
	--disk path=$(pwd)/rootfs.qcow2,format=qcow2,bus=scsi \
	--location $(pwd)/${ISONAME},initrd=install/initrd.gz,kernel=install/vmlinuz \
	--initrd-inject preseed.cfg \
	--extra-args="auto=true priority=critical preseed/file=/preseed.cfg earlyprintk console=tty0 console=ttyS0,115200 " \
	--graphics none \
	--console pty,target_type=serial \
	--os-variant ubuntu18.04 \
	--check all=off \
	--debug \
	--qemu-commandline='-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny'

echo "virt ret=$?"
sync

lsof rootfs.qcow2
if [ $? -ne 0 ]; then
	size=$(du -s rootfs.qcow2 | awk '{print $1}')
	if [ "$size" -gt 204800 ]; then
		qemu-img snapshot -c 'install os' rootfs.qcow2
		qemu-img snapshot -l rootfs.qcow2
	else
		echo "rootfs.qcow2 size too small, skip snapshot"
	fi
fi

exit 0
