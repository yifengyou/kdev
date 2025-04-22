#!/bin/bash

virsh destroy kdev-openeuler22.03-lts-sp1 || :
virsh undefine kdev-openeuler22.03-lts-sp1 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

if [ ! -f openEuler-22.03-LTS-SP1-x86_64-dvd.iso ]; then
	wget -c https://mirrors.huaweicloud.com/openeuler/openEuler-22.03-LTS-SP1/ISO/x86_64/openEuler-22.03-LTS-SP1-x86_64-dvd.iso
fi

virt-install --connect qemu:///system \
	--name kdev-openeuler22.03-lts-sp1 \
	--os-variant centos7.0 \
	--ram 4096 \
	--vcpus 16 \
	--graphics spice,gl.enable=no,listen=none \
	--video qxl \
	--network network=default,model=e1000e \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=virtio-scsi \
	--location openEuler-22.03-LTS-SP1-x86_64-dvd.iso \
	--initrd-inject ks.cfg \
	--extra-args="inst.ks=file:///ks.cfg console=ttyS0,115200 console=tty0 level=10 net.ifnames=0 " \
	--check all=off

sync
sleep 3

qemu-img snapshot -c 'install os' rootfs.qcow2
qemu-img snapshot -l rootfs.qcow2

exit 0
	--graphics none \
	--graphics spice,gl.enable=no,listen=none \
	--video qxl \
