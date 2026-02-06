#!/bin/bash

set -euxo pipefail

WORKDIR=$(pwd)
export build_tag="armbian_${set_release}_${set_desktop}"
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
# Task: Build Root Filesystem (rootfs) using Armbian Build System          #
#                                                                          #
# The BRANCH variable selects the kernel version and support level:        #
#   - edge    : Latest mainline kernel (e.g., 6.10+) — bleeding-edge,      #
#               may include experimental features or instability.          #
#   - current : Stable mainline kernel (e.g., 6.6 LTS) — recommended for   #
#               general use; balances new features and reliability.        #
#   - legacy  : Vendor-provided kernel (e.g., Rockchip 5.10) — intended    #
#               for compatibility with proprietary drivers or older BSPs.  #
#                                                                          #
# Note: Only the rootfs is needed; kernel, U-Boot, and disk images are     #
#       not required for this stage.                                       #
#==========================================================================#
if [ -z "${set_desktop}" ] || [ -z "${set_release}" ]; then
  echo "skip rootfs build"
  echo "Build completed successfully!"
  exit 0
fi
mkdir -p ${WORKDIR}/rootfs
cd ${WORKDIR}/rootfs
if [ "${set_desktop}" == "mini" ]; then
  BUILD_DESKTOP="BUILD_DESKTOP=no"
else
  BUILD_DESKTOP=" \
      BUILD_DESKTOP=yes \
      DESKTOP_APPGROUPS_SELECTED=remote_desktop \
      DESKTOP_ENVIRONMENT=${set_desktop} \
      DESKTOP_ENVIRONMENT_CONFIG_NAME=config_base"
fi
git clone -q --single-branch \
  --depth=1 \
  --branch=main \
  https://github.com/armbian/build.git armbian.git
ls -alh ${WORKDIR}/rootfs/armbian.git
cd ${WORKDIR}/rootfs/armbian.git
./compile.sh RELEASE=${set_release} \
  BOARD=nanopct6 \
  BRANCH=current \
  BUILD_MINIMAL=no \
  BUILD_ONLY=default \
  HOST=armbian \
  ${BUILD_DESKTOP} \
  EXPERT=yes \
  KERNEL_CONFIGURE=no \
  COMPRESS_OUTPUTIMAGE="sha,img,xz" \
  VENDOR="Armbian" \
  SHARE_LOG=yes
ls -alh ${WORKDIR}/rootfs/armbian.git/output/images/

# extract rootfs
chmod +x ${WORKDIR}/kdevbuild/extract-rootfs-from-armbian.sh
${WORKDIR}/kdevbuild/extract-rootfs-from-armbian.sh ${WORKDIR}/rootfs/armbian.git/output/images/
ls -alh ${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img
md5sum ${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img

# archive rootfs image
rar a ${WORKDIR}/release/${build_tag}.rar ${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img
ls -alh ${WORKDIR}/release/${build_tag}.rar
md5sum ${WORKDIR}/release/${build_tag}.rar

echo "Build completed successfully!"
exit 0
