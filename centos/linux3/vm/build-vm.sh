#!/bin/bash

virsh destroy kdev-centos7 || :
virsh undefine kdev-centos7 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

if [ ! -f CentOS-7-x86_64-Minimal-2009.iso ]; then
	wget -c https://mirrors.hostever.com/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso
fi

virt-install --connect qemu:///system \
	--name kdev-centos7 \
	--os-type linux \
	--os-variant centos7.0 \
	--ram 4096 \
	--hvm \
	--vcpus 16 \
	--boot hd \
	--graphics none \
	--location CentOS-7-x86_64-Minimal-2009.iso \
	--network network=default,model=e1000e \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=virtio-scsi \
	--extra-args="text inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 level=10 ks=http://192.168.33.99/ks/centos7.9.cfg console=tty0 console=ttyS0,115200" \
	--check all=off

sync
sleep 1

qemu-img snapshot -c 'install os' rootfs.qcow2
qemu-img snapshot -l rootfs.qcow2

exit 0
