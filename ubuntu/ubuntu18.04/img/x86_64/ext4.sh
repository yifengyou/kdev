#!/bin/bash

set -x

# 参数配置
TARGET_DIR="./rootfs"
MIRROR="https://mirrors.ustc.edu.cn/ubuntu-ports/"  # 使用国内镜像加速
ARCH="amd64"
RELEASE="bionic"
EXT4_IMAGE="rootfs.ext4"
SQUASHFS_IMAGE="rootfs.squashfs"
INCLUDE_PACKAGES=$(tr '\n' ',' < packages.list | sed 's/,$//')

if [ ! -d rootfs ] ; then
	echo "bootstrap rootfs not found!"
	exit 1
fi

# 计算所需空间（增加10%余量）
SIZE=$( du -s ${TARGET_DIR} | awk '{print int(($1 * 1.2 ) / 4)}')
BLOCK_SIZE=4096

# 创建空白镜像文件
dd if=/dev/zero of=${EXT4_IMAGE} bs=${BLOCK_SIZE} count=${SIZE}
mkfs.ext4 -F ${EXT4_IMAGE}

# 挂载并复制文件
TEMP_MOUNT=$(mktemp -d)
mount -o loop ${EXT4_IMAGE} ${TEMP_MOUNT}
cp -a ${TARGET_DIR}/. ${TEMP_MOUNT}/
umount ${TEMP_MOUNT}
rmdir ${TEMP_MOUNT}

ls -lh *.ext4
md5sum *.ext4
echo "All done!"
