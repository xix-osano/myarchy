# Ensure git settings live under ~/.config
mkdir -p ~/.config/git
touch ~/.config/git/config

# Set common git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch main

# Prompt for Git username and email using gum (if not provided)
if [[ -z "${OMARCHY_USER_NAME//[[:space:]]/}" ]]; then
  OMARCHY_USER_NAME=$(gum input --placeholder "Your Git username" --prompt "  Username: ")
fi

if [[ -z "${OMARCHY_USER_EMAIL//[[:space:]]/}" ]]; then
  OMARCHY_USER_EMAIL=$(gum input --placeholder "you@example.com" --prompt "  Email: ")
fi

# Confirm with a styled gum display
gum style --border normal --margin "1 2" --padding "1 3" --border-foreground 212 \
  "Configuring Git identity:" \
  "\n    Name : $OMARCHY_USER_NAME" \
  "\n    Email: $OMARCHY_USER_EMAIL"

# Set Git identity
git config --global user.name "$OMARCHY_USER_NAME"
git config --global user.email "$OMARCHY_USER_EMAIL"

gum confirm "Save these settings globally?" && {
  echo -e "\e[32mGit configured successfully.\e[0m"
} || {
  echo -e "\e[33mAborted Git configuration.\e[0m"
}
