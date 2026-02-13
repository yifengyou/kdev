#!/bin/bash

set -euxo pipefail

WORKDIR=$(pwd)
export build_tag="${set_vendor}_${set_version}_arm64"
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
  zip zlib1g-dev zstd binwalk ripgrep sudo
localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 || true
mkdir -p ${WORKDIR}/rockdev
mkdir -p ${WORKDIR}/release

#==========================================================================#
# Task: Build Root Filesystem (rootfs) using FNOS Build System             #
#==========================================================================#
if [ -z "${set_vendor}" ] || [ -z "${set_version}" ]; then
  echo "skip rootfs build"
  echo "Build completed successfully!"
  exit 0
fi
mkdir -p ${WORKDIR}/fnos
cd ${WORKDIR}/fnos

# download official web list
if ! wget --no-check-certificate -q https://www.fnnas.com/download-arm -O download-arm; then
  echo "下载失败"
  exit 1
fi
ls -alh download-arm

IMG_PATTERN="/rock-5b/"
TARGET_URL=$(grep -o 'https://iso\.liveupdate\.fnnas\.com[^"[:space:]]*img\.gz' download-arm | sort -u | grep "${IMG_PATTERN}" | grep "${set_version}" | head -1)
if [ -z "${TARGET_URL}" ]; then
  echo "${TARGET_URL} is null, failed to download"
fi

GZ_FILE=$(basename ${TARGET_URL})

TARGET_URL=$(curl -sS -X POST 'https://www.fnnas.com/api/download-sign' -H 'Content-Type: application/json' -d '{"url":"https://iso.liveupdate.fnnas.com/arm/trim/1.1.19/rock-5b/fnos_Mainland-PE_arm_1.1.19_rock-5b_620.img.gz"}' | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
if [ -z "${TARGET_URL}" ]; then
  echo "${TARGET_URL} is null, failed to download"
fi

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
        if ($4+0 > max) { max = $4+0; s = $2+0; n = $4+0 }
    }
    END { print s, n }
')

[ -z "$sectors" ] && {
  echo "No partition found"
  exit 1
}

echo "Extracting partition (start=$start, sectors=$sectors) → rootfs.img"
dd if="$img" of=rootfs.img bs=512 skip="$start" count="$sectors" conv=sparse

ls -alh ${WORKDIR}/fnos/rootfs.img
file ${WORKDIR}/fnos/rootfs.img

USED_BLOCKS=$(resize2fs -P rootfs.img 2>/dev/null | grep -o '[0-9]*' | tail -1)
BLOCK_SIZE=$(tune2fs -l rootfs.img | grep "Block size" | awk '{print $3}')
TARGET_BLOCKS=$(echo "$USED_BLOCKS * 1.3 / 1" | bc)
e2fsck -f -y rootfs.img
resize2fs rootfs.img ${TARGET_BLOCKS}

ls -alh ${WORKDIR}/fnos/rootfs.img

# push ${set_vendor}_${set_version}.tar to release
rar a ${WORKDIR}/release/${build_tag}.rar rootfs.img
ls -alh ${WORKDIR}/release/${build_tag}.rar
md5sum ${WORKDIR}/release/${build_tag}.rar

echo "Build completed successfully!"
exit 0
