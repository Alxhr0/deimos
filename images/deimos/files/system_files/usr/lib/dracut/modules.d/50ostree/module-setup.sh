#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
#
# Dracut module for OSTree on Void Linux (non-systemd / runit)

installkernel() {
    instmods erofs overlay btrfs
}

check() {
    # Verify that the required OSTree binary exists
    if [[ -x /usr/lib/ostree/ostree-prepare-root ]]; then
        return 0
    fi

    return 1
}

depends() {
    # Ensure basic dracut filesystems/mount tools are loaded
    return 0
}

install() {
    # Install the core binary
    dracut_install /usr/lib/ostree/ostree-prepare-root

    # Copy OSTree configuration files
    for r in /usr/lib /etc; do
        if test -f "$r/ostree/prepare-root.conf"; then
            inst_simple "$r/ostree/prepare-root.conf"
        fi
    done

    if test -f "/etc/ostree/initramfs-root-binding.key"; then
        inst_simple "/etc/ostree/initramfs-root-binding.key"
    fi

    # Install dracut hook for non-systemd (runit) initramfs execution
    # This hook executes right before mounting real rootfs or pivoting
    inst_hook pre-mount 10 "$moddir/ostree-prepare-root-hook.sh"
}