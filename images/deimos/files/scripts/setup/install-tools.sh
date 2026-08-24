#!/bin/bash

set -ouex pipefail

xbps-install -y -Su


xbps-install -y -S base-devel openssl-devel fuse3-devel meson wget git rust cargo go-md2man ostree libostree-devel pkgconf python3-setuptools

# Composefs
cd /tmp
wget https://github.com/composefs/composefs/releases/download/v1.0.8/composefs-1.0.8.tar.xz
tar -xvf composefs-1.0.8.tar.xz
cd composefs-1.0.8
meson setup build --prefix=/usr
ninja -C build
ninja -C build install

# Bootc

git clone "https://github.com/bootc-dev/bootc.git" /tmp/bootc
make -C /tmp/bootc bin install-all PREFIX=/usr
rm -rf /tmp/bootc

