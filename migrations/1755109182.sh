#!/bin/bash
echo "Resetting DNS configuration to DHCP (removing any forced Cloudflare or Quad9 DNS settings)..."

# Purpose:
# - Reset DNS to use DHCP-provided settings by default
# - Backup existing /etc/systemd/resolved.conf
# - Remove any forced Cloudflare or Quad9 DNS entries
# - Maintain .local domain compatibility for local dev
# - Users can re-enable Cloudflare or Quad9 via: omarchy-setup-dns <provider>

if [ -f /etc/systemd/resolved.conf ]; then
  # Backup current config with timestamp
  backup_timestamp=$(date +"%Y%m%d%H%M%S")
  sudo cp /etc/systemd/resolved.conf "/etc/systemd/resolved.conf.bak.${backup_timestamp}"
  echo "Backup created: /etc/systemd/resolved.conf.bak.${backup_timestamp}"

  # Remove existing DNS and FallbackDNS entries
  sudo sed -i '/^DNS=/d' /etc/systemd/resolved.conf
  sudo sed -i '/^FallbackDNS=/d' /etc/systemd/resolved.conf
  sudo sed -i '/^DNSOverTLS=/d' /etc/systemd/resolved.conf

  # Reinstate blank DNS fields to ensure DHCP is used
  sudo tee -a /etc/systemd/resolved.conf >/dev/null <<'EOF'
[Resolve]
DNS=
FallbackDNS=
DNSOverTLS=no
EOF

  # Remove any custom Omarchy-specific systemd-networkd overrides
  if [ -f /etc/systemd/network/99-omarchy-dns.network ]; then
    sudo rm -f /etc/systemd/network/99-omarchy-dns.network
    sudo systemctl restart systemd-networkd
    echo "Removed /etc/systemd/network/99-omarchy-dns.network override."
  fi

  # Restart resolver to apply clean state
  sudo systemctl restart systemd-resolved

  echo
  echo "✅ DNS configuration reset to DHCP (router/ISP DNS in use)."
  echo "You can re-enable secure DNS anytime:"
  echo "  - Cloudflare: sudo omarchy-setup-dns Cloudflare"
  echo "  - Quad9:      sudo omarchy-setup-dns Quad9"
  echo
else
  echo "⚠️  /etc/systemd/resolved.conf not found. systemd-resolved may not be in use."
fi

# echo "Reset DNS configuration to DHCP (remove forced Cloudflare DNS)"

# # Reset DNS to use DHCP by default instead of forcing Cloudflare
# # This preserves local development environments (.local domains, etc.)
# # Users can still opt-in to Cloudflare DNS using: omarchy-setup-dns cloudflare

# if [ -f /etc/systemd/resolved.conf ]; then
#   # Backup current config with timestamp
#   backup_timestamp=$(date +"%Y%m%d%H%M%S")
#   sudo cp /etc/systemd/resolved.conf "/etc/systemd/resolved.conf.bak.${backup_timestamp}"

#   # Remove explicit DNS entries to use DHCP
#   sudo sed -i '/^DNS=/d' /etc/systemd/resolved.conf
#   sudo sed -i '/^FallbackDNS=/d' /etc/systemd/resolved.conf

#   # Add empty DNS entries to ensure DHCP is used
#   echo "DNS=" | sudo tee -a /etc/systemd/resolved.conf >/dev/null
#   echo "FallbackDNS=" | sudo tee -a /etc/systemd/resolved.conf >/dev/null

#   # Remove any forced DNS config from systemd-networkd
#   if [ -f /etc/systemd/network/99-omarchy-dns.network ]; then
#     sudo rm -f /etc/systemd/network/99-omarchy-dns.network
#     sudo systemctl restart systemd-networkd
#   fi

#   # Restart systemd-resolved to apply changes
#   sudo systemctl restart systemd-resolved

#   echo "DNS configuration reset to use DHCP (router DNS)"
#   echo "To use Cloudflare DNS, run: omarchy-setup-dns Cloudflare"
# fi