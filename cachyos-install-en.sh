#!/usr/bin/env bash
# cachyos-install-en.sh
# Wrapper to install the BC-250 40 CU patch on CachyOS / Arch Linux

set -euo pipefail

echo "================================================="
echo "   BC-250 40 CU Unlocker - CachyOS / Arch Edition"
echo "================================================="

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo."
  exit 1
fi

echo "================================================="
echo " IMPORTANT: Prerequisites"
echo "================================================="
echo "For this script to work properly, you MUST have:"
echo " 1. Installed and configured redbeard1083's bc250-toolkit."
echo " 2. Flashed the modified BIOS on your BC-250."
echo ""
read -p "Do you meet both requirements? (Press 'y' to continue, or any other key to cancel): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled. Please ensure you meet the prerequisites first."
    exit 1
fi

echo "[1/4] Installing system dependencies..."
pacman -S --needed --noconfirm base-devel zstd git

# Dynamically detect current kernel package to install its headers
KERNEL_PKG=$(pacman -Qo /usr/lib/modules/$(uname -r)/kernel 2>/dev/null | awk '{print $5}')
if [ -n "$KERNEL_PKG" ]; then
    HEADER_PKG="${KERNEL_PKG}-headers"
    echo "Installing headers for the current kernel: $HEADER_PKG"
    pacman -S --needed --noconfirm "$HEADER_PKG"
else
    echo "Warning: Could not dynamically detect the kernel package."
    echo "Make sure you have the correct headers installed (e.g. linux-cachyos-headers)."
fi

echo "[2/4] Running module compilation..."
# Call the original script just to build and install the module
if [ ! -f "./scripts/bc250-enable-40cu.sh" ]; then
    echo "Error: ./scripts/bc250-enable-40cu.sh not found."
    echo "Make sure to run this script from the root of the repository."
    exit 1
fi

./scripts/bc250-enable-40cu.sh build

echo "[3/4] Configuring kernel parameters (modprobe)..."
CONF40="/etc/modprobe.d/bc250-40cu.conf"
printf '# BC-250 40 CU re-enablement\noptions amdgpu bc250_cc_write_mode=3\n' > "$CONF40"
echo "Modprobe file created: $CONF40"

echo "[4/4] Rebuilding initramfs (mkinitcpio)..."
# Vital on Arch/CachyOS to load the patched module early on boot (KMS)
mkinitcpio -P

echo "================================================="
echo "All done! The module and initramfs have been successfully updated."
echo "IMPORTANT: If you use Limine and the system asks to confirm (limine-mkinitcpio), press 'Y'."
echo "To apply changes and enjoy your 40 CUs, please reboot your system:"
echo "   sudo reboot"
echo "================================================="
