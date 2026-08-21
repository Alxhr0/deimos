#!/bin/bash
# /usr/lib/dracut/modules.d/50bootc/module-setup.sh

installkernel() {
    instmods erofs overlay
}

check() {
    return 0
}

depends() {
    return 0
}

install() {
    # Install bootc initramfs binary helper
    dracut_install /usr/lib/bootc/initramfs-setup

    # Bundle composefs mount config if available
    [[ -e /usr/lib/composefs/setup-root-conf.toml ]] && \
        inst_simple /usr/lib/composefs/setup-root-conf.toml

    # Register as a dracut hook prior to pivot (replacing the systemd unit)
    inst_hook pre-pivot 10 "$moddir/bootc-setup-root-hook.sh"
}