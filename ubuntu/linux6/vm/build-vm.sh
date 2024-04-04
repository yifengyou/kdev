#!/bin/bash

virsh destroy vm-ubuntu24 || :
virsh undefine vm-ubuntu24 --nvram || :

if [ -f rootfs.qcow2 ];then
	rm -f rootfs.qcow2
fi

if [ ! -f rootfs.qcow2 ];then
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync
sleep 1

if [ ! -f noble-live-server-amd64.iso ]; then
	wget -c http://cdimage.ubuntu.com/ubuntu-server/daily-live/pending/noble-live-server-amd64.iso
fi

virt-install \
	--name vm-ubuntu24 \
	--os-variant ubuntu20.04 \
	--ram 4096 \
	--vcpus 16 \
	--graphics none \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=virtio-scsi \
	--initrd-inject user-data \
	--initrd-inject meta-data \
	--location /data/8T/img/iso/ubuntu/server/noble-live-server-amd64.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
	--extra-args="priority=critical console=ttyS0,115200 autoinstall ds=nocloud-net;s=http://192.168.33.99/ks/ubuntu/ cloud-config-url=/dev/null  root=/dev/ram0" \
	--check all=off

qemu-img snapshot -c 'install os' rootfs.qcow2
qemu-img snapshot -l rootfs.qcow2

exit 0
