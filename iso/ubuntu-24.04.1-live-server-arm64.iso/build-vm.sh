#!/bin/bash

ISOURL="https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04.1-live-server-amd64.iso"
ISOURL="https://mirrors.aliyun.com/ubuntu-releases/24.04/ubuntu-24.04.1-live-server-arm64.iso"
ISOURL="https://releases.ubuntu.com/24.04/ubuntu-24.04.1-live-server-arm64.iso"
ISOURL="https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04.1-live-server-arm64.iso"

WORKDIR=`pwd`
FILE_SERVER_PORT="63336"
VMNAME="kdev-$RANDOM"
ISONAME=$(basename ${ISOURL})
LOGNAME="kdev.log"
JOBS=`nproc`

sudo apt-get install -y \
  tmux \
  qemu-system-arm \
  qemu-system-gui \
  qemu-efi-aarch64 \
  qemu-utils \
  ipxe-qemu

fileserver=$(lsof -ti :${FILE_SERVER_PORT})
if [ ! -z "${fileserver}" ]; then
	kill -9 ${fileserver}
fi

if [ -f rootfs.qcow2 ]; then
	lsof rootfs.qcow2
	if [ $? -eq 0 ]; then
		echo "kdev: rootfs.qcow2 is inuse"
		exit 1
	fi
	rm -f rootfs.qcow2
	qemu-img create -f qcow2 rootfs.qcow2 500G
else
	qemu-img create -f qcow2 rootfs.qcow2 500G
fi
echo "kdev: rootfs.qcow2 ready!"

sync

if [ ! -f "${ISONAME}" ]; then
	aria2c ${ISOURL}
	if [ $? -ne 0 ] ; then
		echo "kdev: download ${ISONAME} failed!"
		exit 1
	fi
fi
ls -alh ${ISONAME}
echo "kdev: ${ISONAME} ready!"

touch meta-data user-data vendor-data ${LOGNAME}

python3 -m http.server ${FILE_SERVER_PORT} --directory $(pwd) &
echo "kdev: http server ready!"

cleanup() {
	fileserver=$(lsof -ti :${FILE_SERVER_PORT})
	if [ ! -z "${fileserver}" ]; then
		kill -9 ${fileserver}
	fi
	umount -l mnt
	rmdir mnt
}
trap cleanup EXIT

mkdir -p mnt
mount ${ISONAME} mnt
if [ $? -ne 0 ]; then
  echo "kdev: mount ${ISONAME} failed!"
  exit 1
fi

ls -alh mnt/casper
if [ $? -ne 0 ]; then
	echo "kdev: casper does't exists in ${ISONAME}"
	exit 1
fi

if [ ! -f mnt/casper/vmlinuz ] ; then
  echo "casper/vmlinuz does't exists!"
  exit 1
fi

if [ ! -f mnt/casper/initrd ] ; then
  echo "casper/initrd does't exists!"
  exit 1
fi

ls -alh /dev/kvm
ip -br a
virsh net-list --all

sudo qemu-system-aarch64 \
  -name kdev-ubuntu2404 \
  -machine virt \
  -cpu max \
  -accel kvm \
  -semihosting \
  -drive file=/usr/share/AAVMF/AAVMF_CODE.fd,format=raw,if=pflash \
  -smp ${JOBS} \
  -m 4096 \
  -cdrom ${ISONAME} \
  -device virtio-scsi-pci,id=scsi \
  -drive file=rootfs.qcow2,format=qcow2,if=virtio \
  -boot order=dc \
  -kernel mnt/casper/vmlinuz \
  -initrd mnt/casper/initrd \
  -append 'ds=nocloud-net;s=http://192.168.122.1:63336/ cloud-config-url=/dev/null autoinstall earlyprintk ignore_loglevel console=ttyAMA0,115200n8 earlycon=pl011,mmio,0x09000000 level=10 ' \
  -serial mon:stdio \
  -net nic \
  -net user,net=192.168.122.0/24,host=192.168.122.1 \
  -nographic

ls -alh rootfs.qcow2

exit 0

  -accel kvm \


#sudo qemu-system-aarch64 \
#  -name kdev-ubuntu2404 \
#  -machine virt \
#  -cpu max \
#  -semihosting \
#  -drive file=/usr/share/AAVMF/AAVMF_CODE.fd,format=raw,if=pflash \
#  -smp ${JOBS} \
#  -m 4096 \
#  -cdrom ${ISONAME} \
#  -device virtio-scsi-pci,id=scsi \
#  -drive file=rootfs.qcow2,format=qcow2,if=virtio \
#  -boot order=dc \
#  -kernel mnt/casper/vmlinuz \
#  -initrd mnt/casper/initrd \
#  -append 'ds=nocloud-net;s=http://192.168.122.1:63336/ cloud-config-url=/dev/null autoinstall earlyprintk ignore_loglevel console=ttyAMA0,115200n8 earlycon=pl011,mmio,0x09000000 level=10 systemd.mask=snapd.service systemd.mask=snapd.seeded.service systemd.mask=casper-md5check.service ' \
#  -serial mon:stdio \
#  -net nic \
#  -net user,net=192.168.122.0/24,host=192.168.122.1 \
#  -nographic

#tmux new-session -d -s kdev \
#"sudo qemu-system-aarch64 \
#  -name kdev-ubuntu2404 \
#  -machine virt \
#  -cpu max \
#  -drive file=/usr/share/AAVMF/AAVMF_CODE.fd,format=raw,if=pflash \
#  -smp ${JOBS} \
#  -m 4096 \
#  -cdrom ${ISONAME} \
#  -device virtio-scsi-pci,id=scsi \
#  -drive file=rootfs.qcow2,format=qcow2,if=virtio \
#  -boot order=dc \
#  -kernel mnt/casper/vmlinuz \
#  -initrd mnt/casper/initrd \
#  -append 'ds=nocloud-net;s=http://192.168.122.1:63336/ cloud-config-url=/dev/null autoinstall earlyprintk ignore_loglevel console=ttyAMA0,115200n8 earlycon=pl011,mmio,0x09000000 level=10 systemd.mask=snapd.service systemd.mask=snapd.seeded.service ' \
#  -serial file:kdev.log \
#  -net nic \
#  -net user,net=192.168.122.0/24,host=192.168.122.1 \
#  -display none"
#
#if [ $? -ne 0 ] ; then
#	echo "kdev: qemu exit with error"
#	exit 1
#fi

sync
sleep 20
ps aux|grep qemu
#ps aux|grep tmux
#tmux ls
#tail -f ${LOGNAME} &

while true ; do
#	ps aux|grep qemu-system-aarch64 |grep -v grep &> /dev/null
#	if [ $? -ne 0 ] ; then
#		break
#	fi
	ls -alh rootfs.qcow2
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
		echo "kdev: rootfs.qcow2 size too small, skip snapshot"
	fi
fi

exit 0
