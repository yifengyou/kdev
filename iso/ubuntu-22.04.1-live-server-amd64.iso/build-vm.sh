#!/bin/bash

ISOURL="https://old-releases.ubuntu.com/releases/22.04.1/ubuntu-22.04.1-live-server-amd64.iso"

WORKDIR=`pwd`
FILE_SERVER_PORT="63336"
VMNAME="kdev-$RANDOM"
ISONAME=$(basename ${ISOURL})
LOGNAME="kdev.log"

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
	umount -l mnt || :

}
trap cleanup EXIT

mkdir mnt
mount ${ISONAME} mnt || :
ls -alh mnt/casper

qemu-system-x86_64 \
	-name "kdev-ubuntu24" \
	-machine pc,accel=kvm \
	-cpu host \
	-smp 4 \
	-m 4096 \
	-cdrom ${WORKDIR}/${ISONAME} \
	-device virtio-scsi-pci,id=scsi \
	-drive file=${WORKDIR}/rootfs.qcow2,format=qcow2,if=virtio \
	-boot order=dc \
	-kernel ${WORKDIR}/mnt/casper/vmlinuz \
	-initrd ${WORKDIR}/mnt/casper/initrd \
	-append "ds=nocloud-net;s=http://192.168.122.1:63336/ cloud-config-url=/dev/null autoinstall earlyprintk console=ttyS0,115200n8" \
	-serial file:${LOGNAME} \
	-net nic -net user,net=192.168.122.0/24,host=192.168.122.1 \
	-display none \
	--daemonize

tail -f ${LOGNAME} &

while true ; do
	ps aux|grep qemu-system-x86_64 |grep -v grep &> /dev/null
	if [ $? -ne 0 ] ; then
		break
	fi
	sleep 3
done

sync

lsof rootfs.qcow2
if [ $? -ne 0 ]; then
	size=$(du -s rootfs.qcow2 | awk '{print $1}')
	if [ "$size" -gt 204800 ]; then
		qemu-img snapshot -c 'install os' rootfs.qcow2
		qemu-img snapshot -l rootfs.qcow2
		ls -alh rootfs.qcow2
	else
		echo "rootfs.qcow2 size too small, skip snapshot"
	fi
fi

umount mnt -l || true
rmdir mnt || true

exit 0
