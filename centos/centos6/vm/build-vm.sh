#!/bin/bash

virsh destroy kdev-centos6 || :
virsh undefine kdev-centos6 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

if [ ! -f CentOS-6.10-x86_64-minimal.iso ]; then
	wget -c /data/8T/img/centos/CentOS-6.10-x86_64-minimal.iso
fi

virt-install --connect qemu:///system \
	--name kdev-centos6 \
	--os-variant ubuntu10.04 \
	--ram 4096 \
	--vcpus 16 \
	--graphics none \
	--network network=default,model=e1000e \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=auto \
	--location CentOS-6.10-x86_64-minimal.iso \
	--initrd-inject ks.cfg \
	--extra-args="ks=file:///ks.cfg console=ttyS0,115200 rd.live.check=false" \
	--check all=off

sync
sleep 1

qemu-img snapshot -c 'install os' rootfs.qcow2
qemu-img snapshot -l rootfs.qcow2

exit 0
	--extra-args="ks=file:///ks.cfg console=ttyS0,115200" \
