#!/bin/bash

ISOURL="https://mirror.nju.edu.cn/rocky-vault/9.2/isos/x86_64/Rocky-9.2-x86_64-minimal.iso"
WORKDIR=$(pwd)
FILE_SERVER_PORT=$(shuf -i 20000-65535 -n 1)
ISONAME=$(basename ${ISOURL})
JOBS=$(nproc)

if [ "$(id -u)" != "0" ]; then
	echo "must run as root"
	exit 1
fi

PKGS=(
	"tmux"
	"qemu-system-arm"
	"qemu-system-gui"
	"qemu-utils"
	"ipxe-qemu"
	"libvirt-daemon-system"
	"virtinst"
	"cpu-checker"
	"aria2"
)
MISSING=()

for p in "${PKGS[@]}"; do
	if ! dpkg -s "$p" &>/dev/null; then
		MISSING+=("$p")
		echo "❌ 缺失: $p"
	else
		echo "✅ 已有: $p"
	fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
	echo "--------------------------------"
	sudo apt-get update && sudo apt-get install -y "${MISSING[@]}"
else
	echo "--------------------------------"
	echo "✨ 所有软件包均已安装。"
fi

fileserver=$(lsof -ti :${FILE_SERVER_PORT})
if [ ! -z "${fileserver}" ]; then
	kill -9 ${fileserver}
fi

if [ -f rootfs.qcow2 ]; then
	size=$(du -s rootfs.qcow2 | awk '{print $1}')
	if [ "$size" -gt 204800 ]; then
		echo "rootfs.qcow2 already ok!"
		ls -alh rootfs.qcow2
		exit 0
	fi
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
	which aria2c
	if [ $? -eq 0 ]; then
		aria2c --max-tries=10 --retry-wait=5 ${ISOURL}
	fi
fi

if [ ! -f "${ISONAME}" ]; then
	which wget
	if [ $? -eq 0 ]; then
		wget -c ${ISOURL}
	fi
fi

if [ ! -f "${ISONAME}" ]; then
	which curl
	if [ $? -eq 0 ]; then
		curl -o ${ISONAME} ${ISOURL}
	fi
fi

if [ ! -f "${ISONAME}" ]; then
	echo "kdev: cound't download ${ISONAME}"
	exit 1
fi

ls -alh ${ISONAME}
echo "kdev: ${ISONAME} ready!"

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

if [ ! -f mnt/images/pxeboot/vmlinuz ]; then
	echo "casper/vmlinuz does't exists!"
	exit 1
fi

if [ ! -f mnt/images/pxeboot/initrd.img ]; then
	echo "casper/initrd does't exists!"
	exit 1
fi

qemu-system-x86_64 \
	-name "${ISONAME%.*}" \
	-machine q35,accel=kvm \
	-cpu host \
	-smp 4 \
	-m 2048 \
	-drive if=pflash,format=raw,unit=0,file=/usr/share/OVMF/OVMF_CODE.fd \
	-drive if=pflash,format=raw,unit=1,file=/usr/share/OVMF/OVMF_VARS.fd \
	-cdrom ${ISONAME} \
	-device virtio-scsi-pci,id=scsi \
	-drive file=rootfs.qcow2,format=qcow2,if=virtio \
	-kernel mnt/images/pxeboot/vmlinuz \
	-initrd mnt/images/pxeboot/initrd.img \
	-append "inst.ks=http://192.168.122.1:${FILE_SERVER_PORT}/ks.cfg inst.stage2=hd:LABEL=Rocky-9-2-x86_64-dvd inst.text inst.cmdline earlyprintk ignore_loglevel console=ttyS0 level=10 net.ifnames=0 biosdevname=0 " \
	-serial mon:stdio \
	-net nic \
	-net user,net=192.168.122.0/24,host=192.168.122.1 \
	-display none \
	-nographic

sync
ls -alh rootfs.qcow2
size=$(du -s rootfs.qcow2 | awk '{print $1}')
if [ "$size" -gt 204800 ]; then
	qemu-img convert -c -O qcow2 rootfs.qcow2 rootfs.qcow2.tmp
	qemu-img check rootfs.qcow2.tmp
	mv rootfs.qcow2.tmp rootfs.qcow2
	ls -alh rootfs.qcow2
	qemu-img snapshot -c 'install os' rootfs.qcow2
	qemu-img snapshot -l rootfs.qcow2
	ls -alh rootfs.qcow2
else
	echo "kdev: rootfs.qcow2 size too small, abort!"
	exit 1
fi

echo "kdev: all done!"
exit 0
