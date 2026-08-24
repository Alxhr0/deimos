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
chown builder:builder -R void-packages

cd void-packages
su builder -c "./xbps-src binary-bootstrap"
su builder -c "sed -i 's|--sysconfdir=/etc|--sysconfdir=/etc --dbdir=/usr/lib/sysimage/var/db/xbps|' srcpkgs/xbps/template"
su builder -c "./xbps-src pkg xbps"
xbps-install -y -R /tmp/void-packages/hostdir/binpkgs -f xbps libxbps

xbps-install -y -S base-devel openssl-devel fuse3-devel meson wget rust cargo go-md2man ostree libostree-devel pkgconf python3-setuptools

# Composefs
cd /tmp
wget https://github.com/composefs/composefs/releases/download/v1.0.8/composefs-1.0.8.tar.xz
tar -xvf composefs-1.0.8.tar.xz
cd composefs-1.0.8
meson setup build --prefix=/usr
ninja -C build
ninja -C build install


# Ostree
export CUSTOM_FLAGS="--without-libsystemd --with-dracut=yes --with-composefs --with-curl --with-openssl --with-ed25519-libsodium --with-modern-grub --disable-static --enable-experimental-api --with-grub2-mkconfig-path=/usr/bin/grub-mkconfig"
cd /tmp/void-packages
su builder -c "perl -0777 -pi -e 's/configure_args=\".*?\"/configure_args=\"$CUSTOM_FLAGS\"/s' /tmp/void-packages/srcpkgs/ostree/template"
su builder -c 'cd /tmp/void-packages && ./xbps-src pkg ostree'
xbps-install -y -R /tmp/void-packages/hostdir/binpkgs -f ostree

# Bootc

git clone "https://github.com/bootc-dev/bootc.git" /tmp/bootc
make -C /tmp/bootc bin install-all PREFIX=/usr
rm -rf /tmp/bootc

