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
