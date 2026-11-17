#!/usr/bin/env bash
# Build and install openFPGALoader on a Raspberry Pi (or any Debian-based host),
# plus the udev rules so the Arty S7 can be programmed without sudo.
set -euo pipefail

sudo apt update
sudo apt install -y git cmake make g++ pkg-config libftdi1-2 libftdi1-dev \
  libhidapi-hidraw0 libhidapi-dev libudev-dev zlib1g-dev

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

git clone https://github.com/trabucayre/openFPGALoader.git "$workdir/openFPGALoader"
mkdir "$workdir/openFPGALoader/build"
cd "$workdir/openFPGALoader/build"
cmake ..
make -j"$(nproc)"
sudo make install

sudo cp ../99-openfpgaloader.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo usermod -aG plugdev "$USER"

echo
echo "Done. Unplug and replug the board, then log out and back in"
echo "so the plugdev group change applies. Test with:"
echo "  openFPGALoader --detect"
