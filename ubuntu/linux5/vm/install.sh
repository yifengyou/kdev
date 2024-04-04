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

virt-install \
	--name vm-ubuntu22 \
	--os-variant ubuntu20.04 \
	--ram 4096 \
	--vcpus 16 \
	--graphics none \
	--disk path=rootfs.qcow2,size=8,format=qcow2,bus=scsi,target.dev=sda \
	--controller type=scsi,model=virtio-scsi \
	--location /data/8T/img/iso/ubuntu/server/ubuntu-22.04-live-server-amd64.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
	--initrd-inject preseed.cfg \
	--extra-args="priority=critical console=ttyS0,115200 autoinstall ds=nocloud-net;s=http://192.168.33.99/ks/ubuntu/ cloud-config-url=/dev/null  root=/dev/ram0" \
	--check all=off

qemu-img snapshot -c 'install os' rootfs.qcow2

exit 0

	--extra-args="priority=critical console=ttyS0,115200" \
	--extra-args="priority=critical console=ttyS0,115200 autoinstall ds=nocloud-net;s=http://192.168.33.99/ks/ubuntu/ cloud-config-url=/dev/null  root=/dev/ram0" \

	--location /data/8T/img/iso/ubuntu/server/ubuntu-22.04-live-server-amd64.iso,kernel=casper/vmlinuz,initrd=casper/initrd \

	--extra-args="auto=true priority=critical preseed/file=/preseed.cfg console=tty0 console=ttyS0,115200 autoinstall ds=nocloud-net;s=http://192.168.33.99/ks/ubuntu/" \
	--boot kernel=install/vmlinuz,initrd=install/initrd.gz,kernel_args="console=ttyS0" \
	--os-variant ubuntu20.10 \
--extra-args="auto=true priority=critical preseed/file=/preseed.cfg console=tty0 console=ttyS0,115200 autoinstall" \
