#!/bin/bash

set -xe

WORKDIR=$(pwd)
sudo yum makecache
sudo yum install -y git make wget tar gcc

cd ${WORKDIR}
MUSL_VERSION="1.2.5"
wget https://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz
tar -xzf musl-$MUSL_VERSION.tar.gz
cd musl-$MUSL_VERSION
./configure
make
sudo make install

export PATH="/usr/local/musl/bin:${PATH}"
echo 'export PATH="/usr/local/musl/bin:${PATH}"' >> ~/.bashrc

cd ${WORKDIR}
git clone https://github.com/Notselwyn/CVE-2024-1086.git CVE-2024-1086.git
cd CVE-2024-1086.git
ls -alh /usr/local/musl/bin/musl-gcc
make
ls -alh exploit
chmod 755 exploit

sudo mkdir -p /data/
sudo cp -a exploit /data/
sudo chown -R kdev:kdev /data


