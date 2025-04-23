#!/bin/bash

set -x

ISOURL="https://iso.kylinos.cn/web_pungi/download/cdn/9D2GPNhvxfsF3BpmRbJjlKu0dowkAc4i/Kylin-Server-V10-SP3-2403-Release-20240426-x86_64.iso"
FILE_SERVER_PORT="62224"
VMNAME="kdev-kylinv10"
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
	--location $(pwd)/${ISONAME},initrd=isolinux/initrd.img,kernel=isolinux/vmlinuz \
	--initrd-inject kickstart.cfg \
	--extra-args="ks=file:///kickstart.cfg console=tty0 console=ttyS0,115200 level=10 net.ifnames=0 ip=dhcp earlyprintk " \
	--graphics none \
	--console pty,target_type=serial \
	--os-variant centos8 \
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
