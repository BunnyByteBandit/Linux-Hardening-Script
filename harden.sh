#!/usr/bin/env bash
# ==============================================================================
# Linux System Hardening & Security Audit Script
# Target: Debian/Ubuntu Linux Systems
# Author: BunnyByteBandit
# ==============================================================================

set -euo pipefail

echo "=================================================="
echo "    🔒 Linux Security Hardening Script "
echo "=================================================="

# Ensure script is executed with root privileges
if [[ "${EUID}" -ne 0 ]]; then
   echo "[!] Error: This script must be run as root." 1>&2
   exit 1
fi

echo "[+] Updating system packages..."
apt-get update -qq && apt-get upgrade -y -qq

echo "[+] Installing security utilities (UFW, Fail2ban)..."
apt-get install -y -qq ufw fail2ban > /dev/null

echo "[+] Configuring Uncomplicated Firewall (UFW)..."
ufw default deny incoming > /dev/null
ufw default allow outgoing > /dev/null
ufw allow 22/tcp comment 'SSH' > /dev/null
ufw --force enable > /dev/null

echo "[+] Hardening OpenSSH Server configuration..."
SSH_CONFIG="/etc/ssh/sshd_config"
if [[ -f "${SSH_CONFIG}" ]]; then
    cp "${SSH_CONFIG}" "${SSH_CONFIG}.bak"
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "${SSH_CONFIG}"
    sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' "${SSH_CONFIG}"
    sed -i 's/^#\?MaxAuthTries.*/MaxAuthTries 3/' "${SSH_CONFIG}"
    systemctl restart sshd || true
fi

echo "[+] Setting strict file permissions on critical system files..."
chmod 600 /etc/shadow
chmod 644 /etc/passwd

echo "=================================================="
echo "[✅] Hardening Complete! Firewall active, SSH secured."
echo "=================================================="
