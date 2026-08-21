#!/usr/bin/bash

set -eoux pipefail

echo "::group::Executing build-initramfs"
trap 'echo "::endgroup::"' EXIT

QUALIFIED_KERNEL="7.2.0_1"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

chmod 0600 /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img
