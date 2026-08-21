#!/bin/bash

set -ouex pipefail
### Install packages


PACKAGES=(
    base-system
    glibc-locales
    bash-completion
    bubblewrap
    cpio
    dracut
    efibootmgr
    iwd
    linux7.2
    linux7.2-headers
    linux-firmware
    linux-firmware-intel
    NetworkManager
    ostree
    btrfs-progs
    e2fsprogs
    xfsprogs
    dosfstools
    skopeo
    dbus
    dbus-glib
    glib
    shadow
    openssh
    sudo
    eudev
    elogind
)


xbps-install -y -S fastfetch NetworkManager

ln -s /etc/sv/elogind /etc/runit/runsvdir/default/
ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/

# Bootc services
ln -s /etc/sv/bootc-root-setup /etc/runit/runsvdir/default/
ln -s /etc/sv/bootc-sysusers-shadow-sync /etc/runit/runsvdir/default/
ln -s /etc/sv/bootc-fetch-apply-updates /etc/runit/runsvdir/default/

mkdir -p /usr/lib/sysimage/var/lib /usr/lib/sysimage/cache/xbps

xbps-install -y -S "${PACKAGES[@]}"

# Rebuild xbps to match the image

cd /tmp
git clone https://github.com/void-linux/void-packages.git --depth=1
chown builder:builder -R void-packages
cd void-packages
su builder -c "./xbps-src binary-bootstrap"
su builder -c "sed -i 's|--sysconfdir=/etc|--sysconfdir=/etc --dbdir=/usr/lib/sysimage/var/db/xbps|' srcpkgs/xbps/template"
su builder -c "./xbps-src pkg xbps"

mkdir -p /usr/lib/sysimage/var/lib /usr/lib/sysimage/cache/xbps

echo "cachedir='/usr/lib/sysimage/cache/xbps'" > /etc/xbps.d/00-cache.conf

printf '[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n' > /usr/lib/ostree/prepare-root.conf

rm -rf /tmp/*
find /run -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true

umount /var/log
umount /var/cache

rm -rf /{boot,home,root,srv,mnt,var,usr/local}

rm -rf /usr/lib/sysimage/{log,cache/xbps}

rm -rf /{build,packages}

mkdir -p /sysroot /boot /usr/lib/ostree /var

ln -sT sysroot/ostree /ostree

ln -sT var/roothome /root

ln -sT var/srv /srv

ln -sT var/mnt /mnt

ln -sT var/opt /opt

ln -sT var/home /home

ln -sT ../var/usrlocal /usr/local