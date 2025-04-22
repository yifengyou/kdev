#!/bin/bash

set -x

TARGET_DIR="./rootfs"
EXT4_IMAGE="rootfs.ext4"

if [ ! -d rootfs ] ; then
	echo "bootstrap rootfs not found!"
	exit 1
fi

SIZE=$( du -s ${TARGET_DIR} | awk '{print int(($1 * 1.2 ) / 4)}')
BLOCK_SIZE=4096

dd if=/dev/zero of=${EXT4_IMAGE} bs=${BLOCK_SIZE} count=${SIZE}
mkfs.ext4 -F ${EXT4_IMAGE}

TEMP_MOUNT=$(mktemp -d)
mount -o loop ${EXT4_IMAGE} ${TEMP_MOUNT}
cp -a ${TARGET_DIR}/. ${TEMP_MOUNT}/
umount ${TEMP_MOUNT}
rmdir ${TEMP_MOUNT}

ls -lh *.ext4
md5sum *.ext4
echo "All done!"
