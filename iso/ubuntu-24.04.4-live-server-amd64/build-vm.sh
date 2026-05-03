#!/bin/bash

ISOURL="https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04-live-server-amd64.iso"
ISOURL="https://mirrors.aliyun.com/ubuntu-releases/24.04/ubuntu-24.04.4-live-server-amd64.iso"
ISOURL="https://releases.ubuntu.com/24.04/ubuntu-24.04.4-live-server-amd64.iso"

WORKDIR=$(pwd)
FILE_SERVER_PORT=$(shuf -i 20000-65535 -n 1)
VMNAME="kdev-$RANDOM"
ISONAME=$(basename ${ISOURL})
JOBS=$(nproc)

fileserver=$(lsof -ti :${FILE_SERVER_PORT})
if [ ! -z "${fileserver}" ]; then
  echo "${FILE_SERVER_PORT} already inuse by ${fileserver}"
  exit 1
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

touch meta-data user-data vendor-data
python3 -m http.server ${FILE_SERVER_PORT} --directory $(pwd) &
echo "kdev: http server ready!"
sleep 5

cleanup() {
  fileserver=$(lsof -ti :${FILE_SERVER_PORT})
  if [ ! -z "${fileserver}" ]; then
    kill -9 ${fileserver}
  fi
  umount -l mnt
  rmdir
}
trap cleanup EXIT

mkdir mnt
mount ${ISONAME} mnt
if [ $? -ne 0 ]; then
  echo "kdev: mount ${ISONAME} failed!"
  exit 1
fi

if [ ! -f ${WORKDIR}/mnt/casper/vmlinuz ]; then
  echo "casper/vmlinuz does't exists!"
  exit 1
fi

if [ ! -f ${WORKDIR}/mnt/casper/initrd ]; then
  echo "casper/initrd does't exists!"
  exit 1
fi

qemu-system-x86_64 \
  -name "${ISONAME%.*}" \
  -machine q35,accel=kvm \
  -cpu host \
  -smp ${JOBS} \
  -m 4096 \
  -drive if=pflash,format=raw,unit=0,file=/usr/share/OVMF/OVMF_CODE.fd \
  -drive if=pflash,format=raw,unit=1,file=/usr/share/OVMF/OVMF_VARS.fd \
  -cdrom "${WORKDIR}/${ISONAME}" \
  -device virtio-scsi-pci,id=scsi \
  -drive file=${WORKDIR}/rootfs.qcow2,format=qcow2,if=virtio \
  -boot order=dc \
  -kernel ${WORKDIR}/mnt/casper/vmlinuz \
  -initrd ${WORKDIR}/mnt/casper/initrd \
  -append "ds=nocloud-net;s=http://10.0.2.1:${FILE_SERVER_PORT}/ cloud-config-url=/dev/null autoinstall earlyprintk console=ttyS0,115200n8" \
  -net user,host=10.0.2.1 \
  -net nic,model=e1000 \
  -display none \
  -serial mon:stdio \
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
