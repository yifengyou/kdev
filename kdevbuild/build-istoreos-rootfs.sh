#!/bin/bash

set -uxo pipefail

WORKDIR=$(pwd)
export build_tag="${set_vendor}_${set_version}_arm64"
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
# Task: Build Root Filesystem (rootfs) using istoresos Build System             #
#==========================================================================#
if [ -z "${set_vendor}" ] || [ -z "${set_version}" ]; then
  echo "skip rootfs build"
  echo "Build completed successfully!"
  exit 0
fi
mkdir -p ${WORKDIR}/istoresos
cd ${WORKDIR}/istoresos

# download official web list
if ! wget --no-check-certificate -q https://fw.koolcenter.com/iStoreOS/h88k/  -O download-arm; then
  echo "下载失败"
  exit 1
fi
ls -alh download-arm

GZ_FILE=$(grep -oP 'href="\K[^"]*\.img\.gz' download-arm | sort -u | grep "${set_version}" | head -1)
if [ -z "${GZ_FILE}" ]; then
  echo "${GZ_FILE} is null, failed to download"
fi

TARGET_URL="https://fw.koolcenter.com/iStoreOS/h88k/${GZ_FILE}"

aria2c --check-certificate=false \
  --max-connection-per-server=16 \
  --split=16 \
  --human-readable=true \
  --summary-interval=5 \
  -o ${GZ_FILE} \
  "${TARGET_URL}"

ls -alh
gunzip -kdf "${GZ_FILE}"
ls -alh
img=$(ls *.img | head -n1)

read start sectors < <(fdisk -l "$img" | awk -v img="$img" '
    $1 ~ img && NF >= 6 {
        count++
        if (count == 2) {
            s = $2+0
            n = $4+0
        }
    }
    END { print s, n }
')

[ -z "$sectors" ] && {
  echo "No partition found"
  exit 1
}

echo "Extracting partition (start=$start, sectors=$sectors) → rootfs.img"
dd if="$img" of=rootfs.img bs=512 skip="$start" count="$sectors" conv=sparse

mv rootfs.img temp.img
mkdir -p /mnt
mount temp.img /mnt
sync
SIZE_MB=$(du -sm /mnt | cut -f1)
IMG_SIZE=$((SIZE_MB * 13 / 10 + 100))
dd if=/dev/zero of=rootfs.img bs=1M count=$IMG_SIZE
mkfs.ext4 rootfs.img
mkdir -p /ext4
mount rootfs.img /ext4
cp -a /mnt/* /ext4/
sync
umount /mnt
umount /ext4

ls -alh rootfs.img
file rootfs.img
if find rootfs.img -type f -size +8G | grep -q .; then
  echo "rootfs.img is too bigger! >8G"
  exit 1
fi

# push ${set_vendor}_${set_version}.tar to release
rar a ${WORKDIR}/release/${build_tag}.rar rootfs.img
ls -alh ${WORKDIR}/release/${build_tag}.rar
md5sum ${WORKDIR}/release/${build_tag}.rar

echo "Build completed successfully!"
exit 0
