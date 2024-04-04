#!/bin/bash

virsh destroy kdev-ubuntu14 || :
virsh undefine kdev-ubuntu14 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

if [ ! -f ubuntu-14.04-server-amd64.iso ]; then
	wget -c https://old-releases.ubuntu.com/releases/14.04.4/ubuntu-14.04-server-amd64.iso
fi

virt-install --connect qemu:///system \
	--name kdev-ubuntu14 \
	--os-variant ubuntu14.04 \
	--ram 4096 \
	--vcpus 16 \
	--graphics none \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=auto \
	--location ubuntu-14.04-server-amd64.iso \
	--initrd-inject preseed.cfg \
	--extra-args="auto=true priority=critical preseed/file=/preseed.cfg console=tty0 console=ttyS0,115200 autoinstall" \
	--check all=off


qemu-img snapshot -c 'install os' rootfs.qcow2
qemu-img snapshot -l rootfs.qcow2

exit 0
