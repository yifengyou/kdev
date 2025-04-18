#!/bin/bash

set -x

# 参数配置
TARGET_DIR="./rootfs"
MIRROR="https://mirrors.ustc.edu.cn/ubuntu/"  # 使用国内镜像加速
ARCH="x86_64"
RELEASE="bionic"
EXT4_IMAGE="rootfs.ext4"
SQUASHFS_IMAGE="rootfs.squashfs"
COMPRESS_LEVEL=9  # 压缩级别 1-9
INCLUDE_PACKAGES=$(tr '\n' ',' < packages.list | sed 's/,$//')

# 安装依赖
apt-get update
apt-get install -y debootstrap squashfs-tools e2fsprogs

echo "extra package:${INCLUDE_PACKAGES}"
# 创建基础文件系统
debootstrap \
    --arch=${ARCH} \
    --components=main,universe \
    --include=${INCLUDE_PACKAGES} \
    ${RELEASE} \
    ${TARGET_DIR} \
    ${MIRROR}
if [ $? -ne 0 ] ; then
	echo "debootstrap failed!"
	exit 1
fi

# 基础系统配置
chroot ${TARGET_DIR} /bin/bash << EOF
apt-get update
apt-get install -y systemd-sysv locales
locale-gen en_US.UTF-8
echo root:linux | chpasswd
rm -rf /var/lib/apt/lists/*
EOF

echo "All done!"
