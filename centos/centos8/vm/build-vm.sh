#!/bin/bash

virsh destroy kdev-centos8 || :
virsh undefine kdev-centos8 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

if [ ! -f CentOS-8.5.2111-x86_64-dvd1.iso ]; then
	wget -c https://mirrors.aliyun.com/centos-vault/centos/8/isos/x86_64/CentOS-8.5.2111-x86_64-dvd1.iso
fi

virt-install --connect qemu:///system \
	--name kdev-centos8 \
	--os-variant centos7.0 \
	--ram 4096 \
	--vcpus 16 \
	--graphics spice,gl.enable=no,listen=none \
	--video qxl \
	--network network=default,model=e1000e \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=virtio-scsi \
	--location CentOS-8.5.2111-x86_64-dvd1.iso \
	--initrd-inject ks.cfg \
	--extra-args="ks=file:///ks.cfg console=ttyS0,115200 console=tty0 level=10 net.ifnames=0 " \
	--check all=off

sync
sleep 1

qemu-img snapshot -c 'install os' rootfs.qcow2
qemu-img snapshot -l rootfs.qcow2

exit 0
