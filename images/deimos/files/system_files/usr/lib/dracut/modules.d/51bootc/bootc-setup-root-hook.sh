#!/bin/sh
# /usr/lib/dracut/modules.d/50bootc/bootc-setup-root-hook.sh

if [ -f /etc/initrd-release ] && grep -q '\bcomposefs\b' /proc/cmdline; then
    if [ -x /usr/lib/bootc/initramfs-setup ]; then
        /usr/lib/bootc/initramfs-setup setup-root
    fi
fi