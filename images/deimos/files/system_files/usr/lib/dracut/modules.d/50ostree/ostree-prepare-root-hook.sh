#!/bin/sh
# Dracut pre-mount hook for OSTree under non-systemd initramfs

if [ -x /usr/lib/ostree/ostree-prepare-root ]; then
    # /sysroot is where dracut mounts the root device before pivot_root
    if [ -d /sysroot ]; then
        /usr/lib/ostree/ostree-prepare-root /sysroot
    fi
fi