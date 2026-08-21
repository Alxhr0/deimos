#!/bin/bash

set -ouex pipefail


mkdir -p /usr/lib/sysimage/var/lib /usr/lib/sysimage/cache/xbps
mkdir -p /usr/lib/sysimage/var/db/xbps/keys

cp -a /var/db/xbps/keys/. /usr/lib/sysimage/var/db/xbps/keys/

# Rebuild xbps to match the image

cd /tmp
git clone https://github.com/void-linux/void-packages.git --depth=1
chown builder:builder -R void-packages
cd void-packages
su builder -c "./xbps-src binary-bootstrap"
su builder -c "sed -i 's|--sysconfdir=/etc|--sysconfdir=/etc --dbdir=/usr/lib/sysimage/var/db/xbps|' srcpkgs/xbps/template"
su builder -c "./xbps-src pkg xbps"
xbps-install -y -R /tmp/void-packages/hostdir/binpkgs -f xbps libxbps


## Install packages
PACKAGES=(
    base-system
    glibc-locales
    bash-completion
    bubblewrap
    cpio
    dracut
    efibootmgr
    iwd
    linux-mainline
    linux-mainline-headers
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
    gtk-update-icon-cache
    fastfetch
)


xbps-install -y -S "${PACKAGES[@]}"

ln -s /etc/sv/elogind /etc/runit/runsvdir/default/
ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/

# Bootc services
ln -s /etc/sv/bootc-root-setup /etc/runit/runsvdir/default/
ln -s /etc/sv/bootc-sysusers-shadow-sync /etc/runit/runsvdir/default/
ln -s /etc/sv/bootc-fetch-apply-updates /etc/runit/runsvdir/default/


mkdir -p /usr/lib/sysimage/var/lib /usr/lib/sysimage/cache/xbps

echo "cachedir='/usr/lib/sysimage/cache/xbps'" > /etc/xbps.d/00-cache.conf

printf '[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n' > /usr/lib/ostree/prepare-root.conf

find /run -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true


mkdir -p /usr/lib/dracut/modules.d

if [ -d /deimos_core/system_files/usr ]; then
    cp -a /deimos_core/system_files/usr/. /usr/
fi

if [ -d /deimos_core/system_files/etc ]; then
    cp -a /deimos_core/system_files/etc/. /etc/
fi