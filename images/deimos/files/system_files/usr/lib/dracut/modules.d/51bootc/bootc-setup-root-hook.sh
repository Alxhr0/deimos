#!/bin/sh
# Execute bootc root setup unconditionally before pre-pivot

if [ -x /usr/lib/bootc/initramfs-setup ]; then
    /usr/lib/bootc/initramfs-setup setup-root
fi