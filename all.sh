#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

#-------------------------------------------------------------------------------
# 0. Prompt for Git user info
#-------------------------------------------------------------------------------

# Ensure we have gum available
if ! command -v gum &>/dev/null; then
  sudo pacman -S --needed --noconfirm gum
fi

# Prompt for Git identity
OMARCHY_USER_NAME=$(gum input --prompt "  Enter your Git username: " --placeholder "Your name")
OMARCHY_USER_EMAIL=$(gum input --prompt "  Enter your Git email: " --placeholder "you@example.com")

# Confirm identity visually
gum style --border normal --margin "1 2" --padding "1 3" --border-foreground 212 \
  "Git Identity Configuration:" \
  "\n    Name : $OMARCHY_USER_NAME" \
  "\n    Email: $OMARCHY_USER_EMAIL"

gum confirm "Proceed with these settings?" || exit 1

#-------------------------------------------------------------------------------
# 1. Define Omarchy locations
#-------------------------------------------------------------------------------
export OMARCHY_PATH="$HOME/.local/share/omarchy"
export OMARCHY_INSTALL="$OMARCHY_PATH/install"
export OMARCHY_INSTALL_LOG_FILE="/var/log/omarchy-install.log"
export PATH="$OMARCHY_PATH/bin:$PATH"
export OMARCHY_USER_NAME
export OMARCHY_USER_EMAIL

#-------------------------------------------------------------------------------
# 2. Begin modular installation
#-------------------------------------------------------------------------------
source "$OMARCHY_INSTALL/helpers/all.sh"
source "$OMARCHY_INSTALL/preflight/all.sh"
source "$OMARCHY_INSTALL/packaging/all.sh"
source "$OMARCHY_INSTALL/config/all.sh"
source "$OMARCHY_INSTALL/login/all.sh"
source "$OMARCHY_INSTALL/post-install/all.sh"
