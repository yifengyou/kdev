#!/bin/bash

set -uxo pipefail

WORKDIR=$(pwd)
export build_tag="${set_vendor}_${set_release}_${set_version}_${set_arch}"
export DEBIAN_FRONTEND=noninteractive

#==========================================================================#
#                        init build env                                    #
#==========================================================================#
apt-get update
apt-get install -y ca-certificates
apt-get install -y --no-install-recommends \
  acl aptly aria2 axel bc binfmt-support binutils-aarch64-linux-gnu bison \
  bsdextrautils btrfs-progs build-essential busybox ca-certificates ccache \
  clang coreutils cpio crossbuild-essential-arm64 cryptsetup curl \
  debian-archive-keyring debian-keyring debootstrap device-tree-compiler \
  dialog dirmngr distcc dosfstools dwarves e2fsprogs expect f2fs-tools \
  fakeroot fdisk file flex gawk gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi \
  gdisk git gnupg gzip htop imagemagick jq kmod lib32ncurses-dev \
  lib32stdc++6 libbison-dev libc6-dev-armhf-cross libc6-i386 libcrypto++-dev \
  libelf-dev libfdt-dev libfile-fcntllock-perl libfl-dev libfuse-dev \
  libgcc-12-dev-arm64-cross libgmp3-dev liblz4-tool libmpc-dev libncurses-dev \
  libncurses5 libncurses5-dev libncursesw5-dev libpython2.7-dev \
  libpython3-dev libssl-dev libusb-1.0-0-dev linux-base lld llvm locales \
  lsb-release lz4 lzma lzop make mtools ncurses-base ncurses-term \
  nfs-kernel-server ntpdate openssl p7zip p7zip-full parallel parted patch \
  patchutils pbzip2 pigz pixz pkg-config pv python2 python2-dev python3 \
  python3-dev python3-distutils python3-pip python3-setuptools \
  python-is-python3 qemu-user-static rar rdfind rename rsync sed \
  squashfs-tools swig tar tree u-boot-tools udev unzip util-linux uuid \
  uuid-dev uuid-runtime vim wget whiptail xfsprogs xsltproc xxd xz-utils \
  zip zlib1g-dev zstd binwalk ripgrep sudo libguestfs-tools
localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 || true
mkdir -p ${WORKDIR}/release

#==========================================================================#
# Task: Build Root Filesystem (rootfs)                                     #
#==========================================================================#
if [ -z "${set_vendor}" ] || [ -z "${set_release}" ]; then
  echo "skip rootfs build"
  echo "Build completed successfully!"
  exit 0
fi
mkdir -p ${WORKDIR}/ubuntu
cd ${WORKDIR}/ubuntu

# https://cloud-images.ubuntu.com/daily/server/bionic/current/bionic-server-cloudimg-amd64.img
# https://cloud-images.ubuntu.com/daily/server/bionic/current/bionic-server-cloudimg-arm64.img

# https://cloud-images.ubuntu.com/daily/server/focal/current/focal-server-cloudimg-amd64.img
# https://cloud-images.ubuntu.com/daily/server/focal/current/focal-server-cloudimg-arm64.img

# https://cloud-images.ubuntu.com/daily/server/jammy/current/jammy-server-cloudimg-amd64.img
# https://cloud-images.ubuntu.com/daily/server/jammy/current/jammy-server-cloudimg-arm64.img

# https://cloud-images.ubuntu.com/daily/server/noble/current/noble-server-cloudimg-amd64.img
# https://cloud-images.ubuntu.com/daily/server/noble/current/noble-server-cloudimg-arm64.img

export QCOW2="${set_release}-server-cloudimg-arm64.img"
export QCOW2_URL="https://cloud-images.ubuntu.com/daily/server/${set_release}/current/${QCOW2}"

aria2c --check-certificate=false \
  --max-connection-per-server=16 \
  --split=16 \
  --human-readable=true \
  --summary-interval=5 \
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
  BLOCK_SIZE=$(tune2fs -l rootfs.img | grep "Block size" | awk '{print $3}')
  TARGET_BLOCKS=$(echo "$USED_BLOCKS * 1.3 / 1" | bc)
  if [ -z "$USED_BLOCKS" ] || [ -z "$BLOCK_SIZE" ] || [ -z "$TARGET_BLOCKS" ]; then
    echo "not available for resize2fs"
  else
    e2fsck -f -y rootfs.img
    resize2fs rootfs.img ${TARGET_BLOCKS}
  fi
elif file rootfs.img | grep -qi "xfs filesystem"; then
  echo "skip xfs shrink"
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

rar a ${WORKDIR}/release/${build_tag}.rar rootfs.img
ls -alh ${WORKDIR}/release/${build_tag}.rar
md5sum ${WORKDIR}/release/${build_tag}.rar

echo "Build completed successfully!"
exit 0
