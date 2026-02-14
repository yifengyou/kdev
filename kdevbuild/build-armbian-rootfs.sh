#!/bin/bash

set -uxo pipefail

WORKDIR=$(pwd)
export build_tag="armbian_${set_release}_${set_desktop}_aarch64"
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
git clone --single-branch \
  --branch=main \
  https://github.com/armbian/build.git armbian.git

ls -alh ${WORKDIR}/rootfs/armbian.git

cd ${WORKDIR}/rootfs/armbian.git
git checkout main
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
cd ${WORKDIR}/rootfs/armbian.git/output/images/
ARMBIAN_IMG=$(ls *.img.xz | head -n1)
xz -kdc ${ARMBIAN_IMG} >armbian.img
PARTITION_INFO=$(fdisk -l armbian.img | awk '/^Device/{flag=1; next} flag{print $1, $2, $3; exit}')
START_SECTOR=$(echo "${PARTITION_INFO}" | awk '{print $2}')
END_SECTOR=$(echo "${PARTITION_INFO}" | awk '{print $3}')
COUNT=$((END_SECTOR - START_SECTOR + 1))
dd if=armbian.img of=rootfs.img \
  bs=512 \
  skip="${START_SECTOR}" \
  count="${COUNT}" \
  status=progress
ls -alh ${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img
file ${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img

#==========================================================================#
#                        Hack rootfs via chroot                            #
#==========================================================================#

ROOTFS_IMG="${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img"
MOUNT_POINT="${WORKDIR}/rootfs_mount"
mkdir -p "${MOUNT_POINT}"
mount -o loop "${ROOTFS_IMG}" "${MOUNT_POINT}"

mount -t proc /proc "${MOUNT_POINT}/proc" || true
mount -o bind /dev "${MOUNT_POINT}/dev" || true
mount -o bind /sys "${MOUNT_POINT}/sys" || true

cat >"${MOUNT_POINT}/hack-rootfs.sh" <<'EOF'
#!/bin/bash
set -ex

if [ -f /usr/bin/systemctl ]; then
  systemctl daemon-reload
fi

if [ -f /lib/systemd/system/lightdm.service ]; then
  systemctl enable lightdm
fi

if [ -f /lib/systemd/system/gdm.service ]; then
  if ! grep -q '\[Install\]' /lib/systemd/system/gdm.service; then
    echo -e "\n[Install]\nWantedBy=graphical.target" >> /lib/systemd/system/gdm.service
  fi
  systemctl enable gdm
  if [ -f /etc/gdm3/daemon.conf ]; then
    sed -i '/\[security\]/a AllowRoot=true' /etc/gdm3/daemon.conf
  fi
  if [ -f /etc/pam.d/gdm-password ]; then
    sed -i 's/^auth.*pam_succeed_if\.so.*user != root.*/#&/' /etc/pam.d/gdm-password
  fi
fi

if [ -f /etc/rc.local ]; then
  chmod +x /etc/rc.local
fi

sed -i 's/NanoPC T6/KDEV/g' /etc/armbian-*

echo "root:admin" | chpasswd

adduser --quiet --disabled-password --gecos "" admin
echo "admin:admin" | chpasswd
usermod -aG sudo admin

if [ -f /root/.not_logged_in_yet ]; then
  rm -f /root/.not_logged_in_yet
fi

EOF

chmod +x "${MOUNT_POINT}/hack-rootfs.sh"
chroot "${MOUNT_POINT}" /hack-rootfs.sh

rm -f "${MOUNT_POINT}/hack-rootfs.sh"
umount "${MOUNT_POINT}/proc" || true
umount "${MOUNT_POINT}/dev" || true
umount "${MOUNT_POINT}/sys" || true
umount "${MOUNT_POINT}"
rmdir "${MOUNT_POINT}"
sync

# archive rootfs image
cd ${WORKDIR}/rootfs/armbian.git/output/images/

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
