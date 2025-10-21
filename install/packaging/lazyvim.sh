echo "============================================"
echo "     Archy Linux Lazyvim Setup"
echo "============================================"
echo

log() { printf "\033[1;32m==>\033[0m %s\n" "$@"; }

# ---------- config ----------
NVIM_MIN="0.9.0"
LAZYVIM_REPO="https://github.com/LazyVim/starter"
# ----------------------------

command -v nvim >/dev/null || {
  log "==> Installing neovim ..."
  sudo pacman -S --needed --noconfirm neovim
}

# version check (semver)
current=$(nvim --version | head -n1 | grep -oP '\d+\.\d+\.\d+')
if [[ "$(printf '%s\n' "$NVIM_MIN" "$current" | sort -V | head -n1)" != "$NVIM_MIN" ]]; then
  echo "ERROR: Neovim $current < required $NVIM_MIN"
  echo "Upgrade first (yay -S neovim-nightly if needed)."
  exit 1
fi

conf_dir="$HOME/.config/nvim"
backup_dir="${conf_dir}.bak.$(date +%Y%m%d%H%M%S)"

if [[ -d "$conf_dir" ]]; then
  log "==> Backing up existing config → $backup_dir"
  mv "$conf_dir" "$backup_dir"
fi

log "==> Cloning LazyVim starter ..."
git clone --depth=1 "$LAZYVIM_REPO" "$conf_dir"

# remove the upstream .git so it becomes *your* dot-folder
rm -rf "$conf_dir/.git"

# --- Launch Neovim to trigger bootstrap ---
#log "==> Bootstrapping LazyVim plugins..."
#nvim --headless "+Lazy! sync" +qa

# -------------- Done -------------------------
echo "✔ LazyVim installed."
echo "  Open nvim once to download plugins / LSP / treesitter"
echo "  Then read the docs inside"