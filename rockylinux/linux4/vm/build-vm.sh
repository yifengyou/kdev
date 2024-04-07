#!/bin/bash

virsh destroy kdev-rockylinux8 || :
virsh undefine kdev-rockylinux8 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

if [ ! -f Rocky-8.9-x86_64-minimal.iso ]; then
	wget -c https://mirrors.ustc.edu.cn/rocky/8.9/isos/x86_64/Rocky-8.9-x86_64-minimal.iso
fi

virt-install --connect qemu:///system \
	--name kdev-rockylinux8 \
	--os-variant centos7.0 \
	--ram 4096 \
	--vcpus 16 \
	--graphics spice,gl.enable=no,listen=none \
	--video qxl \
	--network network=default,model=e1000e \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=virtio-scsi \
	--location Rocky-8.9-x86_64-minimal.iso \
	--initrd-inject ks.cfg \
	--extra-args="inst.ks=file:///ks.cfg console=ttyS0,115200 console=tty0 level=10 net.ifnames=0 " \
	--check all=off

sync
sleep 1

qemu-img snapshot -c 'install os' rootfs.qcow2
qemu-img snapshot -l rootfs.qcow2

exit 0
