#!/bin/bash

set -ouex pipefail

xbps-install -y -Su

# Rebuild xbps to match the image

mkdir -p /usr/lib/sysimage/var/lib /usr/lib/sysimage/cache/xbps
mkdir -p /usr/lib/sysimage/var/db/xbps/keys

cp -a /var/db/xbps/keys/. /usr/lib/sysimage/var/db/xbps/keys/

xbps-install -y -S git

cd /tmp
git clone https://github.com/void-linux/void-packages.git --depth=1
cp -r /deimos_core/packages/* void-packages/srcpkgs
chown builder:builder -R void-packages

cd void-packages
su builder -c "./xbps-src binary-bootstrap"
su builder -c "sed -i 's|--sysconfdir=/etc|--sysconfdir=/etc --dbdir=/usr/lib/sysimage/var/db/xbps|' srcpkgs/xbps/template"
su builder -c "./xbps-src pkg xbps"
xbps-install -y -R /tmp/void-packages/hostdir/binpkgs -f xbps libxbps

xbps-install -y -S base-devel openssl-devel fuse3-devel meson wget rust cargo go-md2man pkgconf python3-setuptools

# Composefs
cd /tmp/void-packages
echo "libcomposefs.so.1 libcomposefs-1.0_1" >> common/shlibs
su builder -c "./xbps-src pkg composefs"

# Ostree
cd /tmp/void-packages
su builder -c 'cd /tmp/void-packages && ./xbps-src pkg ostree'

xbps-rindex -a /tmp/void-packages/hostdir/binpkgs/*.xbps
xbps-install -y -R /tmp/void-packages/hostdir/binpkgs -f composefs libcomposefs-devel ostree libostree-devel

# Bootc
cd /tmp/void-packages
su builder -c 'cd /tmp/void-packages && ./xbps-src pkg bootc'
xbps-install -y -R /tmp/void-packages/hostdir/binpkgs -f bootc



