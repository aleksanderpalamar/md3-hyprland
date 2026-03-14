#!/bin/bash
# License: GPLv3
# Main Installer for MD3-Hyprland
# Author: Aleksander Palamar

set -euo pipefail

VERSION="1.0.0"

# Prevent running as root
if [ "$EUID" -eq 0 ]; then
    echo "========================================================="
    echo " [!] DO NOT RUN THIS SCRIPT WITH SUDO."
    echo "     / NÃO EXECUTE ESTE SCRIPT COM SUDO."
    echo " yay and makepkg cannot run as root."
    echo " The script will ask for your password when needed."
    echo "========================================================="
    exit 1
fi

# Validate we're running from the project directory
if [ ! -f "$(pwd)/install.sh" ] || [ ! -d "$(pwd)/config" ]; then
    echo "========================================================="
    echo " [!] Please run this script from the project directory."
    echo "     / Execute este script dentro do diretório do projeto."
    echo "     cd /path/to/md3-hyprland-setup && ./install.sh"
    echo "========================================================="
    exit 1
fi

chmod +x scripts/*.sh

clear
echo "========================================="
echo "   MD3 Hyprland Automation Installer"
echo "   v${VERSION}"
echo "========================================="
echo ""

# Step 1/4: Check Environment
echo "[Step 1/4] Checking environment... / Verificando ambiente..."
./scripts/01_check_env.sh
if [ $? -ne 0 ]; then
    echo "Environment check failed. / Verificação do ambiente falhou."
    exit 1
fi

echo ""
read -rp "Press Enter to proceed with installation (or Ctrl+C to cancel)... "

# Step 2/4: Install Packages
echo ""
echo "[Step 2/4] Installing packages... / Instalando pacotes..."
./scripts/02_install_pkgs.sh
if [ $? -ne 0 ]; then
    echo "Package installation failed. / Instalação de pacotes falhou."
    exit 1
fi

# Step 3/4: Link Configs
echo ""
echo "[Step 3/4] Linking configurations... / Vinculando configurações..."
./scripts/03_link_configs.sh

# Step 4/4: Post Install
echo ""
echo "[Step 4/4] Running post-install setup... / Executando pós-instalação..."
./scripts/04_post_install.sh

echo ""
echo "========================================="
echo "   Installation Complete!"
echo "   Instalação Concluída!"
echo "========================================="
echo ""
echo "   Start Hyprland or reboot your session."
echo "   Inicie o Hyprland ou reinicie sua sessão."
echo "========================================="
