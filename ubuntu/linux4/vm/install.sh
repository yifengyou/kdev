#!/bin/bash

virsh destroy vm-ubuntu18 || :
virsh undefine vm-ubuntu18 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

virt-install --connect qemu:///system \
	--name vm-ubuntu18 \
	--os-variant ubuntu18.04 \
	--ram 4096 \
	--vcpus 16 \
	--graphics none \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=virtio-scsi \
	--location /data/8T/img/iso/ubuntu/server/ubuntu-18.04-server-amd64.iso \
	--initrd-inject preseed.cfg \
	--extra-args="auto=true priority=critical preseed/file=/preseed.cfg console=tty0 console=ttyS0,115200 autoinstall" \
	--check all=off

exit 0
