#!/bin/bash

set -x

ISOURL="https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04-live-server-arm64.iso"
FILE_SERVER_PORT="63336"
ISONAME=$(basename ${ISOURL})

# 检查web文件服务器端口是否被占用
fileserver=$(lsof -ti :${FILE_SERVER_PORT})
if [ ! -z "${fileserver}" ]; then
	echo "${FILE_SERVER_PORT} already inuse by ${fileserver}"
	exit 1
fi

virsh destroy kdev-ubuntu24 || :
virsh undefine kdev-ubuntu24 --nvram || :

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
	wget -c ${ISOURL}
fi

touch meta-data user-data

python3 -m http.server ${FILE_SERVER_PORT} --directory $(pwd) &

virt-install \
	--name kdev-ubuntu24 \
	--arch aarch64 \
	--machine virt-5.2 \
	--vcpus 4 \
	--ram 2048 \
	--cpu host-passthrough \
	--boot cdrom \
	--disk path=$(pwd)/rootfs.qcow2,format=qcow2,bus=scsi \
	--location $(pwd)/${ISONAME},initrd=casper/initrd,kernel=casper/vmlinuz \
	--extra-args=" ds=nocloud-net;s=http://192.168.122.1:${FILE_SERVER_PORT} cloud-config-url=/dev/null autoinstall priority=critical console=serial earlyprintk " \
	--features acpi=on \
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

fileserver=$(lsof -ti :${FILE_SERVER_PORT})
if [ ! -z "${fileserver}" ]; then
	kill -9 ${fileserver}
fi

exit 0
