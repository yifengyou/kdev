#!/bin/bash

set -x

IMAGE_NAME="ubuntu:18.04"
MIRROR="https://mirrors.ustc.edu.cn/ubuntu-ports/"
TARGET_DIR="./rootfs"
ARCH="arm64"
RELEASE="bionic"
EXT4_IMAGE="rootfs.ext4"
SQUASHFS_IMAGE="rootfs.squashfs"
COMPRESS_LEVEL=9
INCLUDE_PACKAGES=$(tr '\n' ',' < packages.list | sed 's/,$//')
CONTAINER_NAME=$RANDOM

if ! command -v docker &> /dev/null; then
  echo "command docker not found!"
  exit 1
fi

if [ ! -f packages.list ] ; then
  echo "no packages.list found!"
  exit 1
fi

echo "-> start up docker ${IMAGE_NAME}"
docker run \
  -v `pwd`:/data  \
  --name ${CONTAINER_NAME} \
  -itd $IMAGE_NAME bash

cleanup() {
    echo "clean docker"
    docker rm -f ${CONTAINER_NAME}
}
trap cleanup EXIT

echo "-> apt installation"
docker exec -w /data $CONTAINER_NAME \
  sed -i "s/ports.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

docker exec -w /data $CONTAINER_NAME \
  sed -i "s/security.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

docker exec -w /data $CONTAINER_NAME \
  cat /etc/apt/sources.list \

docker exec -w /data $CONTAINER_NAME \
  apt-get update \

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

if [ $? -ne 0 ] ; then
	echo "debootstrap failed!"
	exit 1
fi

echo "-> config rootfs"
chroot ${TARGET_DIR} /bin/bash << EOF
apt-get update
apt-get install -y systemd-sysv locales
locale-gen en_US.UTF-8
echo root:linux | chpasswd
rm -rf /var/lib/apt/lists/*
EOF

echo "All done!"
