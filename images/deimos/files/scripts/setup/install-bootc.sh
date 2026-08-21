#!/bin/bash

set -ouex pipefail

xbps-install -y -Su

xbps-install -y -S base-devel git rust cargo go-md2man ostree libostree-devel pkgconf python3-setuptools

git clone "https://github.com/bootc-dev/bootc.git" /tmp/bootc
make -C /tmp/bootc bin install-all PREFIX=/usr
rm -rf /tmp/bootc