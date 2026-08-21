#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

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

rm -rf /{boot,home,root,srv,mnt,var,usr/local}

rm -rf /usr/lib/sysimage/{log,cache/pacman/pkg}

rm -rf /{build,packages}

mkdir -p /sysroot /boot /usr/lib/ostree /var

ln -sT sysroot/ostree /ostree

ln -sT var/roothome /root

ln -sT var/srv /srv

ln -sT var/mnt /mnt

ln -sT var/opt /opt

ln -sT var/home /home

ln -sT ../var/usrlocal /usr/local