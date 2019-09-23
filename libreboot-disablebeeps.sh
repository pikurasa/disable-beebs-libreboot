#!/bin/bash

# libreboot-disablebeeps.sh
# version 1.0
# Disable battery beeps and alarm on librebooted Thinkpad laptops.
# Michael McMahon

# License: AGPLv3

# To run this script, boot a Debian based distribution on a Thinkpad laptop with
# libreboot installed, open a terminal, navigate to this directory, and run this
# script with:
#   sudo bash libreboot-disablebeeps.sh

# Based on https://libreboot.org/docs/misc/#power-management-beeps-on-thinkpads

# Initialization checks

# Check for /bin/bash.
if [ "$BASH_VERSION" = '' ]; then
  echo "You are not using bash."
  echo "Use this syntax instead:"
  echo "sudo bash bluearchive.sh"
  exit 1
fi

# Check for root.
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# Check networking
# https://unix.stackexchange.com/questions/190513/shell-scripting-proper-way-to-
#   check-for-internet-connectivity
echo Checking network...
if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "The network is up."
else
  echo "The network is down."
  echo "Check connection and restart script!"
  exit 1
fi

echo "Installing dependencies..."
apt update
apt install -y libftdi1
wget https://www.mirrorservice.org/sites/libreboot.org/release/stable/20160907/libreboot_r20160907_util.tar.xz
tar xvf libreboot_r20160907_util.tar.xz
mkdir -p roms

echo "Extracing libreboot image..."
romfile=roms/t400-$(date +%Y%m%d-%H%M).rom
./libreboot_r20160907_util/flashrom/x86_64/flashrom -p internal -r ./$romfile

echo "Backing up libreboot image..."
cp $romfile $romfile.bak

echo "Modifying libreboot image..."
./libreboot_r20160907_util/nvramtool/x86_64/nvramtool -v

./libreboot_r20160907_util/nvramtool/x86_64/nvramtool -C ./$romfile -w power\_management\_beeps=Disable
./libreboot_r20160907_util/nvramtool/x86_64/nvramtool -C ./$romfile -w low\_battery\_beep=Disable

echo "Flashing modified libreboot image..."
./libreboot_r20160907_util/flashrom/x86_64/flashrom -p internal -w $romfile
