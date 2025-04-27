#!/bin/bash

set -x

TARGET_DIR="./rootfs"
SQUASHFS_IMAGE="rootfs.squashfs"

if [ ! -d rootfs ]; then
	echo "bootstrap rootfs not found!"
	exit 1
fi

mksquashfs ${TARGET_DIR} ${SQUASHFS_IMAGE} \
	-comp xz \
	-Xdict-size 100% \
	-b 1M \
	-noappend \
	-processors $(nproc)

ls -lh *.squashfs
md5sum *.squashfs
echo "All done!"
