#!/bin/bash

set -ouex pipefail

rm -rf /usr/lib/sysimage/{log,cache/xbps}
rm -rf /{build,packages}

rm -rf /{boot,home,opt,root,srv,mnt,var,usr/local}

mkdir -p /sysroot /boot /usr/lib/ostree /var

ln -sT sysroot/ostree /ostree
ln -sT var/roothome /root
ln -sT var/srv /srv
ln -sT var/mnt /mnt
ln -sT var/opt /opt
ln -sT var/home /home
ln -sT ../var/usrlocal /usr/local