#!/bin/bash


if [ -d rootfs ] ; then
	rm -rf rootfs
fi

mkdir -p rootfs
debootstrap \
    --arch=amd64 \
    --variant=minbase \
    --include=vim,net-tools,build-essential \
    --no-check-gpg \
    precise \
    `pwd`/rootfs \
    http://mirrors.ustc.edu.cn/ubuntu-old-releases/ubuntu/
