#!/bin/bash

set -uxo pipefail

WORKDIR=$(pwd)
export build_tag="${set_vendor}_${set_version}"
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
if [ -z "${set_vendor}" ] || [ -z "${set_version}" ]; then
  echo "skip rootfs build"
  echo "Build completed successfully!"
  exit 0
fi
mkdir -p ${WORKDIR}/openwrt
cd ${WORKDIR}/openwrt

# https://downloads.openwrt.org/releases/24.10.4/targets/rockchip/armv8/openwrt-24.10.4-rockchip-armv8-friendlyarm_nanopc-t6-ext4-sysupgrade.img.gz
# https://downloads.openwrt.org/releases/24.10.5/targets/rockchip/armv8/openwrt-24.10.5-rockchip-armv8-friendlyarm_nanopc-t6-ext4-sysupgrade.img.gz

export QCOW2="openwrt-${set_version}-rockchip-armv8-friendlyarm_nanopc-t6-ext4-sysupgrade.img.gz"
export QCOW2_URL="https://downloads.openwrt.org/releases/${set_version}/targets/rockchip/armv8/${QCOW2}"
export build_tag="${set_vendor}_${set_version}_${set_arch}"

aria2c --check-certificate=false \
  --max-connection-per-server=16 \
  --split=16 \
  --human-readable=true \
  --summary-interval=5 \
  -o ${QCOW2} \
  "${QCOW2_URL}"

gunzip ${QCOW2}
ls -alh ${QCOW2%.gz}
mv ${QCOW2%.gz} disk.img

read start end < <(
  sgdisk -p disk.img | awk '
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
dd if=disk.img of=rootfs.img bs=512 skip="$start" count="$sectors" conv=sparse

# resize filesystem
while [ -f rootfs.img ]; do
  ls -alh rootfs.img
  file rootfs.img

  # Skip if file is too small
  [ $(stat -c%s rootfs.img) -lt $((4 * 1024 ** 3)) ] && break

  case $(file rootfs.img) in
  *ext[234]*filesystem*)
    # Get filesystem parameters
    BLOCK_SIZE=$(tune2fs -l rootfs.img | awk -F': *' '/Block size/{print $2}')
    USED_BLOCKS=$(resize2fs -P rootfs.img 2>/dev/null | grep -o '[0-9]*$')

    # Validate parameters
    [ -z "$BLOCK_SIZE" ] || [ -z "$USED_BLOCKS" ] && {
      echo "Error: Cannot determine filesystem parameters" >&2
      exit 1
    }

    # Resize with 30% buffer
    e2fsck -f -y rootfs.img &&
      resize2fs rootfs.img $(echo "$USED_BLOCKS * 1.3 / 1" | bc) || exit 1
    ;;

  *xfs*filesystem* | *btrfs*filesystem*)
    echo "Skip $(file rootfs.img | grep -oiE 'xfs|btrfs') shrink" >&2
    ;;

  *)
    echo "Error: Unsupported filesystem type" >&2
    exit 1
    ;;
  esac

  # Size validation
  ls -alh rootfs.img
  [ $(stat -c%s rootfs.img) -gt $((8 * 1024 ** 3)) ] && {
    echo "Error: rootfs.img exceeds 8GB" >&2
    exit 1
  }
done

rar a ${WORKDIR}/release/${build_tag}.rar rootfs.img
ls -alh ${WORKDIR}/release/${build_tag}.rar
md5sum ${WORKDIR}/release/${build_tag}.rar

echo "Build completed successfully!"
exit 0
