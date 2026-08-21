#!/usr/bin/bash

set -eoux pipefail

echo "::group::Executing build-initramfs"
trap 'echo "::endgroup::"' EXIT

QUALIFIED_KERNEL="7.2.0_1"

# Copy the kernel image into the module directory if it isn't there already
if [ -f "/boot/vmlinuz-$QUALIFIED_KERNEL" ]; then
    cp -a "/boot/vmlinuz-$QUALIFIED_KERNEL" "/usr/lib/modules/$QUALIFIED_KERNEL/vmlinuz"
elif [ -f "/boot/vmlinuz" ]; then
    cp -a "/boot/vmlinuz" "/usr/lib/modules/$QUALIFIED_KERNEL/vmlinuz"
fi

/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

chmod 0600 /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img
