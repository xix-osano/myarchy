echo "Migrate from manually downloaded fonts to font packages"
if ! pacman -Q ttf-cascadia-mono-nerd &>/dev/null; then
  sudo pacman -S --noconfirm ttf-cascadia-mono-nerd
  rm -rf ~/.local/share/fonts/Caskaydia*
  fc-cache
fi

if ! pacman -Q ttf-ia-writer &>/dev/null; then
  sudo pacman -S --noconfirm ttf-ia-writer
  rm -rf ~/.local/share/fonts/iAWriterMonoS*
  fc-cache
fi
