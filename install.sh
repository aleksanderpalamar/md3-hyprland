#!/bin/bash
# License: GPLv3
# Main Installer for MD3-Hyprland
# Author: Aleksander Palamar

# Prevent running as root
if [ "$EUID" -eq 0 ]; then
    echo "========================================================="
    echo " [!] POR FAVOR, NÃO EXECUTE ESTE SCRIPT COM SUDO."
    echo " O yay e o makepkg não podem ser executados como root."
    echo " O script pedirá sua senha quando necessário."
    echo "========================================================="
    exit 1
fi

chmod +x scripts/*.sh

clear
echo "========================================="
echo "   MD3 Hyprland Automation Installer"
echo "========================================="
echo ""

# 1. Check Env
./scripts/01_check_env.sh
if [ $? -ne 0 ]; then
    echo "Environment check failed. Exiting."
    exit 1
fi

echo ""
read -p "Press Enter to proceed with installation (or Ctrl+C to cancel)..."

# 2. Install Packages
./scripts/02_install_pkgs.sh
if [ $? -ne 0 ]; then
    echo "Package installation failed. Exiting."
    exit 1
fi

# 3. Link Configs
./scripts/03_link_configs.sh

# 4. Post Install
./scripts/04_post_install.sh

echo ""
echo "========================================="
echo "   Installation Complete!"
echo "========================================="
