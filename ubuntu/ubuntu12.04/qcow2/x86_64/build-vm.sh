#!/bin/bash

set -x

ISOURL="https://old-releases.ubuntu.com/releases/12.04/ubuntu-12.04.5-server-amd64.iso"
FILE_SERVER_PORT="63332"
VMNAME="kdev-ubuntu12"
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
	--disk path=$(pwd)/rootfs.qcow2,format=qcow2,bus=sata \
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




#!/bin/bash

virsh destroy kdev-ubuntu12 || :
virsh undefine kdev-ubuntu12 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

if [ ! -f ubuntu-12.04.5-server-amd64.iso ]; then
	wget -c https://old-releases.ubuntu.com/releases/10.04.0/ubuntu-12.04.5-server-amd64.iso
fi

virt-install --connect qemu:///system \
	--name kdev-ubuntu12 \
	--os-variant ubuntu12.04 \
	--ram 4096 \
	--vcpus 16 \
	--graphics none \
	--network network=default,model=e1000e \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=auto \
	--location ubuntu-12.04.5-server-amd64.iso \
	--initrd-inject preseed.cfg \
	--extra-args="auto=true priority=critical preseed/file=/preseed.cfg console=tty0 console=ttyS0,115200 autoinstall" \
	--check all=off

qemu-img snapshot -c 'install os' rootfs.qcow2
qemu-img snapshot -l rootfs.qcow2

exit 0
