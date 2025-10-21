# Ensure iwd service will be started
sudo systemctl enable iwd.service

# Disable systemd-networkd
sudo systemctl disable systemd-networkd
sudo systemctl mask systemd-networkd

# Prevent systemd-networkd-wait-online timeout on boot
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl mask NetworkManager-wait-online.service

# Ensure network manager is enabled
sudo systemctl enable --now NetworkManager

# Prevent networkmanager-wait-online
sudo systemctl disable networkmanager-wait-online.service
sudo systemctl mask networkmanager-wait-online.service

# ---------- systemd-resolved setup ----------
if ! systemctl is-active --quiet systemd-resolved; then
  log "Enabling systemd-resolved…"
  sudo systemctl enable --now systemd-resolved
else
  log "systemd-resolved already active."
fi

if [[ ! "$(readlink /etc/resolv.conf 2>/dev/null)" =~ resolve ]]; then
  echo "Linking /etc/resolv.conf → systemd-resolved stub..."
  sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
else
  echo "/etc/resolv.conf already linked to systemd-resolved."
fi

# ---------- NetworkManager Integration ----------
CONF_DIR=/etc/NetworkManager/conf.d
sudo mkdir -p "$CONF_DIR"
if ! sudo grep -q "dns=systemd-resolved" "$CONF_DIR/resolved.conf" 2>/dev/null; then
  echo "Pointing NetworkManager to systemd-resolved …"
  printf "%s\n" "[main]" "dns=systemd-resolved" | sudo tee "$CONF_DIR/resolved.conf" >/dev/null
  sudo systemctl restart NetworkManager
  echo "NetworkManager restarted successfully."
fi
