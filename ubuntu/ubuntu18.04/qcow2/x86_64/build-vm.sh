#!/bin/bash


# ISOURL="https://old-releases.ubuntu.com/releases/18.04.4/ubuntu-18.04-server-amd64.iso"
ISOURL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage/releases/bionic/release/ubuntu-18.04.6-server-arm64.iso"

ISONAME=`basename ${ISOURL}`

virsh destroy kdev-ubuntu18 || :
virsh undefine kdev-ubuntu18 --nvram || :

if [ -f rootfs.qcow2 ] ; then
	lsof rootfs.qcow2
	if [ $? -eq 0 ] ; then
		echo "rootfs.qcow2 is inuse"
		exit 1
	fi
	rm -f rootfs.qcow2
else
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync

if [ ! -f "${ISONAME}" ]; then
	wget -c ${ISOURL}
fi

virt-install --connect qemu:///system \
	--name kdev-ubuntu18 \
	--os-variant ubuntu18.04 \
	--ram 4096 \
	--vcpus 8 \
	--graphics none \
	--network network=default,model=e1000e \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=auto \
	--location ubuntu-18.04.6-server-amd64.iso \
	--initrd-inject preseed.cfg \
	--extra-args="auto=true priority=critical preseed/file=/preseed.cfg console=tty0 console=ttyS0,115200 autoinstall" \
	--check all=off


if [ $? -eq 0 ] ; then
	qemu-img snapshot -c 'install os' rootfs.qcow2
	qemu-img snapshot -l rootfs.qcow2
fi

exit 0

