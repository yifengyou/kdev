#!/bin/bash

set -x

IMAGE_NAME="hub.rat.dev/ubuntu:14.04"
ARCH="amd64"
MIRROR="http://archive.ubuntu.com/ubuntu/"
TARGET_DIR="./rootfs"
RELEASE="trusty"
EXT4_IMAGE="rootfs.ext4"
SQUASHFS_IMAGE="rootfs.squashfs"
INCLUDE_PACKAGES=$(tr '\n' ',' <packages.list | sed 's/,$//')
CONTAINER_NAME=${RANDOM}

if ! command -v docker &>/dev/null; then
	echo "command docker not found!"
	exit 1
fi

if [ ! -f packages.list ]; then
	echo "no packages.list found!"
	exit 1
fi

if [ -d rootfs ]; then
	echo "rootfs already exists!"
	exit 1
fi

echo "-> start up docker ${IMAGE_NAME}"
docker run \
	-v $(pwd):/data \
	--name ${CONTAINER_NAME} \
	-itd $IMAGE_NAME bash

cleanup() {
	echo "clean docker"
	docker rm -f ${CONTAINER_NAME}
}
trap cleanup EXIT

echo "-> apt installation"
docker exec -w /data $CONTAINER_NAME \
	cat /etc/apt/sources.list

docker exec -w /data $CONTAINER_NAME \
	apt-get update

docker exec -w /data $CONTAINER_NAME \
	apt-get install -y debootstrap

echo "-> debootstrap building"
docker exec -w /data ${CONTAINER_NAME} \
	/usr/sbin/debootstrap \
	--arch=${ARCH} \
	--components=main,universe \
	--include=${INCLUDE_PACKAGES} \
	${RELEASE} \
	${TARGET_DIR} \
	${MIRROR}

if [ $? -ne 0 ]; then
	echo "debootstrap failed!"
	exit 1
fi

echo "All done!"
