#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/cosmicbuffalo/open-clipboard-links.git"
INSTALL_DIR="$HOME/open-clipboard-links"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/open-clipboard-links"

echo "open-clipboard-links installer"
echo "This will:"
echo "  - clone/update $REPO_URL into $INSTALL_DIR"
echo "  - install a launchd agent into ~/Library/LaunchAgents"
echo "  - write config to $CONFIG_DIR"
echo "  - symlink a CLI into ~/.local/bin"
echo

if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "Found existing install at $INSTALL_DIR, pulling latest..."
  git -C "$INSTALL_DIR" pull --ff-only
else
  echo "Cloning into $INSTALL_DIR..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

exec "$INSTALL_DIR/install.sh"
