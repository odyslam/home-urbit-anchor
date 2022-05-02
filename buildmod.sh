#!/usr/bin/env bash
set -euo pipefail

if [ -f /usr/src/app/wireguard.ko ]
then
        modinfo /usr/src/app/wireguard.ko
        echo "wireguard.ko already exists, skipping module build..."
        exit 0
fi

src="$(find /usr/src/app/wireguard-linux-compat-* -maxdepth 1 -type d -name 'src')"

curl -fsSL "https://files.balena-cloud.com/images/${device_slug}/${os_version/+/%2B}/kernel_source.tar.gz" \
	| tar xz --strip-components=2 -C /usr/src/app/

# build wireguard kernel module
make -C /usr/src/app/build modules_prepare -j"$(nproc)"
make -C /usr/src/app/build M="${src}" -j"$(nproc)"
mv "${src}/wireguard.ko" "/usr/src/app/"

# clean up kernel sources
rm -rf /usr/src/app/build