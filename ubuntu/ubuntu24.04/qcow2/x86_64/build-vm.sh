#!/bin/bash

set -x

ISOURL="https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04-live-server-amd64.iso"
ISOURL="https://mirrors.aliyun.com/ubuntu-releases/24.04/ubuntu-24.04.2-live-server-amd64.iso"
ISOURL="https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso"
FILE_SERVER_PORT="63336"
VMNAME="kdev-ubuntu24"
ISONAME=$(basename ${ISOURL})

fileserver=$(lsof -ti :${FILE_SERVER_PORT})
if [ ! -z "${fileserver}" ]; then
	echo "${FILE_SERVER_PORT} already inuse by ${fileserver}"
	exit 1
fi

virsh destroy ${VMNAME} || :
virsh undefine ${VMNAME} --nvram || :

if [ -f rootfs.qcow2 ]; then
	lsof rootfs.qcow2
	if [ $? -eq 0 ]; then
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
	wget -q -c ${ISOURL}
fi

touch meta-data user-data

python3 -m http.server ${FILE_SERVER_PORT} --directory $(pwd) &

cleanup() {
	fileserver=$(lsof -ti :${FILE_SERVER_PORT})
	if [ ! -z "${fileserver}" ]; then
		kill -9 ${fileserver}
	fi
}
trap cleanup EXIT

virt-install \
	--name ${VMNAME} \
	--arch x86_64 \
	--vcpus 4 \
	--ram 4096 \
	--boot cdrom,hd \
	--disk path=$(pwd)/rootfs.qcow2,format=qcow2,bus=scsi \
	--location $(pwd)/${ISONAME},initrd=casper/initrd,kernel=casper/vmlinuz \
	--extra-args=" ds=nocloud-net;s=http://192.168.122.1:${FILE_SERVER_PORT} cloud-config-url=/dev/null autoinstall earlyprintk console=ttyS0,115200n8 " \
	--graphics none \
	--console pty,target_type=serial \
	--os-variant ubuntu20.04 \
	--check all=off \
	--debug \
	--qemu-commandline='-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny'

echo "virt ret=$?"
sync

lsof rootfs.qcow2
if [ $? -ne 0 ]; then
	size=$(du -s rootfs.qcow2 | awk '{print $1}')
	if [ "$size" -gt 204800 ]; then
		qemu-img snapshot -c 'install os' rootfs.qcow2
		qemu-img snapshot -l rootfs.qcow2
	else
		echo "rootfs.qcow2 size too small, skip snapshot"
	fi
fi

exit 0
