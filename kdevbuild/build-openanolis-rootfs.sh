#!/bin/bash

set -uxo pipefail

WORKDIR=$(pwd)
export DEBIAN_FRONTEND=noninteractive

#==========================================================================#
#                        init build env                                    #
#==========================================================================#
apt-get update
apt-get install -qq -y ca-certificates
apt-get install -qq -y --no-install-recommends \
  acl aptly aria2 axel bc binfmt-support binutils-aarch64-linux-gnu bison \
  bsdextrautils btrfs-progs build-essential busybox ca-certificates ccache \
  clang coreutils cpio crossbuild-essential-arm64 cryptsetup curl \
  debian-archive-keyring debian-keyring debootstrap device-tree-compiler \
  dialog dirmngr distcc dosfstools dwarves e2fsprogs expect f2fs-tools \
  fakeroot fdisk file flex gawk gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi \
  gdisk git gnupg gzip htop imagemagick jq kmod lib32ncurses-dev \
  lib32stdc++6 libbison-dev libc6-dev-armhf-cross libc6-i386 libcrypto++-dev \
  libelf-dev libfdt-dev libfile-fcntllock-perl libfl-dev libfuse-dev \
  libgcc-12-dev-arm64-cross libgmp3-dev liblz4-tool libmpc-dev \
  libpython3-dev libssl-dev libusb-1.0-0-dev linux-base lld llvm locales \
  lsb-release lz4 lzma lzop make mtools ncurses-base ncurses-term \
  nfs-kernel-server ntpdate openssl p7zip p7zip-full parallel parted patch \
  patchutils pbzip2 pigz pixz pkg-config pv python3 \
  python3-dev python3-pip python3-setuptools lvm2 \
  python-is-python3 qemu-user-static rar rdfind rename rsync sed \
  squashfs-tools swig tar tree u-boot-tools udev unzip util-linux uuid \
  uuid-dev uuid-runtime vim wget whiptail xfsprogs xsltproc xxd xz-utils \
  zip zlib1g-dev zstd binwalk ripgrep sudo libguestfs-tools

mkdir -p ${WORKDIR}/release

#==========================================================================#
# Task: Build Root Filesystem (rootfs)                                     #
#==========================================================================#
if [ -z "${set_vendor}" ] || [ -z "${set_version}" ]; then
  echo "skip rootfs build"
  echo "Build completed successfully!"
  exit 0
fi
mkdir -p ${WORKDIR}/openanolis
cd ${WORKDIR}/openanolis

process_qcow2() {
  local QCOW2="$1"
  local QCOW2_URL="$2"

  aria2c --check-certificate=false \
    --max-connection-per-server=16 \
    --split=16 \
    --human-readable=true \
    --summary-interval=30 \
    -o ${QCOW2} \
    "${QCOW2_URL}"

  qemu-img convert -f qcow2 -O raw ${QCOW2} qcow2.raw
  ls -alh qcow2.raw
  fdisk -l qcow2.raw

  read start end < <(
    sgdisk -p qcow2.raw | awk '
    /^ *[0-9]+/ {
      s = $2; e = $3;
      size = e - s + 1;
      if (size > max_size) {
        max_size = size;
        best_s = s;
        best_e = e;
      }
    }
    END {
      if (max_size) print best_s, best_e;
    }'
  )
  sectors=$((end - start + 1))
  if [ -z "$sectors" ]; then
    echo "No partition found"
    exit 1
  fi

  echo "Extracting partition (start=$start, sectors=$sectors) → rootfs.img"
  dd if=qcow2.raw of=rootfs.img bs=512 skip="$start" count="$sectors" conv=sparse

  # resize filesystem
  ls -alh rootfs.img
  file rootfs.img
  if file rootfs.img | grep -qi "ext[234] filesystem"; then
    USED_BLOCKS=$(resize2fs -P rootfs.img 2>/dev/null | grep -o '[0-9]*' | tail -1)
    if [ -z "$USED_BLOCKS" ]; then
      resize2fs -P rootfs.img
      echo "not available for resize2fs"
      exit 1
    fi
    BLOCK_SIZE=$(tune2fs -l rootfs.img | grep "Block size" | awk '{print $3}')
    TARGET_BLOCKS=$(echo "$USED_BLOCKS * 1.3 / 1" | bc)
    if [ -z "$USED_BLOCKS" ] || [ -z "$BLOCK_SIZE" ] || [ -z "$TARGET_BLOCKS" ]; then
      echo "not available for resize2fs"
    else
      e2fsck -f -y rootfs.img
      resize2fs rootfs.img ${TARGET_BLOCKS}
    fi
  elif file rootfs.img | grep -qi "xfs filesystem"; then
    mv rootfs.img xfs.img
    mkdir -p /mnt
    mount xfs.img /mnt
    sync
    SIZE_MB=$(du -sm /mnt | cut -f1)
    IMG_SIZE=$((SIZE_MB * 13 / 10 + 100))
    dd if=/dev/zero of=rootfs.img bs=1M count=$IMG_SIZE
    mkfs.xfs rootfs.img
    mkdir -p /xfs
    mount rootfs.img /xfs
    cp -a /mnt/* /xfs/
    sync
    umount /mnt
    umount /xfs
    ls -alh rootfs.img
    file rootfs.img
  elif file rootfs.img | grep -qi "btrfs filesystem"; then
    echo "skip btrfs shrink"
  else
    echo "rootfs.img is not ext[234]/xfs/btrfs filesystem!"
    exit 1
  fi
  ls -alh rootfs.img
  if find rootfs.img -type f -size +8G | grep -q .; then
    echo "rootfs.img is too bigger! >8G"
    exit 1
  fi

  rar a ${WORKDIR}/release/${QCOW2%.qcow2}.rar rootfs.img
  ls -alh ${WORKDIR}/release/${QCOW2%.qcow2}.rar
  md5sum ${WORKDIR}/release/${QCOW2%.qcow2}.rar

  ls -alh ${WORKDIR}/release/
  df -h
}

rm -f index.html qcow2.raw rootfs.img *.qcow2
if wget --no-check-certificate "https://mirrors.openanolis.cn/anolis/${set_version}/isos/GA/x86_64/"; then
  ls -alh index.html
  for QCOW2 in $(grep -oE 'href="([^"]+\.qcow2)"' index.html | cut -d'"' -f2); do
    rm -f qcow2.raw rootfs.img
    export QCOW2_URL="https://mirrors.openanolis.cn/anolis/${set_version}/isos/GA/x86_64/${QCOW2}"
    process_qcow2 "$QCOW2" "${QCOW2_URL}"
  done
fi

rm -f index.html qcow2.raw rootfs.img *.qcow2
if wget --no-check-certificate "https://mirrors.openanolis.cn/anolis/${set_version}/isos/GA/aarch64/"; then
  ls -alh index.html
  for QCOW2 in $(grep -oE 'href="([^"]+\.qcow2)"' index.html | cut -d'"' -f2); do
    rm -f qcow2.raw rootfs.img
    export QCOW2_URL="https://mirrors.openanolis.cn/anolis/${set_version}/isos/GA/aarch64/${QCOW2}"
    process_qcow2 "$QCOW2" "${QCOW2_URL}"
  done
fi

echo "Build completed successfully!"
exit 0
