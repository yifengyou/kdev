#!/bin/bash

set -x


# ISOURL="https://old-releases.ubuntu.com/releases/18.04.4/ubuntu-18.04-server-arm64.iso"
ISOURL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage/releases/bionic/release/ubuntu-18.04.6-server-arm64.iso"

ISONAME=`basename ${ISOURL}`

virsh destroy kdev-ubuntu18 || :
virsh undefine kdev-ubuntu18 --nvram || :

if [ -f rootfs.qcow2 ] ; then
	lsof rootfs.qcow2
	if [ $? -eq 0 ] ; then
		echo "rootfs.qcow2 is inuse"
		exit 1
	fi
	rm -f rootfs.qcow2
	qemu-img create -f qcow2 rootfs.qcow2 500G
else
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi

sync

if [ ! -f "${ISONAME}" ]; then
	wget -c ${ISOURL}
fi


virt-install \
    --name kdev-ubuntu18 \
    --arch aarch64 \
    --machine virt-5.2 \
    --vcpus 1 \
    --ram 2048 \
    --cpu host-passthrough \
    --boot uefi \
    --disk path=/linux/linux-4.git/kdev.git/ubuntu/ubuntu18.04/qcow2/aarch64/rootfs.qcow2,format=qcow2,bus=scsi \
    --location ${ISONAME} \
    --initrd-inject preseed.cfg \
    --extra-args="auto=true priority=critical preseed/file=/preseed.cfg console=serial earlyprintk level=10 log_level=10 autoinstall" \
    --features acpi=on \
    --graphics none \
    --console pty,target_type=serial \
    --os-variant ubuntu18.04 \
    --check all=off \
    --qemu-commandline='-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny'

sync
sleep 3
lsof rootfs.qcow2
if [ $? -ne 0 ] ; then
	qemu-img snapshot -c 'install os' rootfs.qcow2
	qemu-img snapshot -l rootfs.qcow2
fi

exit 0
