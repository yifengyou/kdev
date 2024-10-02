#!/bin/bash

virsh destroy vm-ubuntu22 || :
virsh undefine vm-ubuntu22 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

curl http://192.168.122.1/ks/ubuntu/ &> /dev/null
if [ $? -ne 0 ] ; then
	echo "this ubuntu version need webserver to setup automatic installation"
	exit 1
fi

if [ ! -f ubuntu-22.04-live-server-amd64.iso ]; then
	wget -c https://old-releases.ubuntu.com/releases/22.04/ubuntu-22.04-live-server-amd64.iso
fi

virt-install \
	--name vm-ubuntu22 \
	--os-variant ubuntu20.04 \
	--ram 4096 \
	--vcpus 16 \
	--graphics none \
	--network network=default,model=e1000e \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=auto \
	--location ubuntu-22.04-live-server-amd64.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
	--initrd-inject user-data \
	--initrd-inject meta-data \
	--extra-args="priority=critical console=ttyS0,115200 autoinstall ds=nocloud-net;s=http://192.168.122.1/ks/ubuntu/ cloud-config-url=/dev/null  root=/dev/ram0" \
	--check all=off

qemu-img snapshot -c 'install os' rootfs.qcow2
qemu-img snapshot -l rootfs.qcow2

exit 0

