#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$PROJECT_DIR/open-clipboard-links.sh"
TEMPLATE_PATH="$PROJECT_DIR/com.cosmicbuffalo.open-clipboard-links.plist.template"
LABEL="com.cosmicbuffalo.open-clipboard-links"
PLIST_DEST="$HOME/Library/LaunchAgents/${LABEL}.plist"
LOG_DIR="$HOME/Library/Logs"
BIN_DEST_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/open-clipboard-links"
DOMAIN="gui/$(id -u)"

chmod +x "$SCRIPT_PATH" "$PROJECT_DIR/bin/open-clipboard-links"

WAS_LOADED=0
launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1 && WAS_LOADED=1

mkdir -p "$CONFIG_DIR"
if [[ ! -f "$CONFIG_DIR/config.sh" ]]; then
  cp "$PROJECT_DIR/config.sh.example" "$CONFIG_DIR/config.sh"
  echo "Created $CONFIG_DIR/config.sh from config.sh.example. Edit it to customize behavior."
fi

mkdir -p "$HOME/Library/LaunchAgents" "$LOG_DIR" "$BIN_DEST_DIR"

sed -e "s|__SCRIPT_PATH__|$SCRIPT_PATH|g" -e "s|__LOG_DIR__|$LOG_DIR|g" \
  "$TEMPLATE_PATH" > "$PLIST_DEST"

ln -sf "$PROJECT_DIR/bin/open-clipboard-links" "$BIN_DEST_DIR/open-clipboard-links"

echo "Installed plist to $PLIST_DEST"
echo "Linked CLI to $BIN_DEST_DIR/open-clipboard-links"

if [[ ":$PATH:" != *":$BIN_DEST_DIR:"* ]]; then
  echo "Warning: $BIN_DEST_DIR is not in your PATH. Add it to your shell profile."
fi

if [[ "$WAS_LOADED" -eq 1 ]]; then
  echo "Restarting $LABEL to pick up the update..."
  launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
  launchctl bootstrap "$DOMAIN" "$PLIST_DEST"
  launchctl kickstart -k "$DOMAIN/$LABEL"
  echo "Restarted $LABEL"
else
  echo "Run 'open-clipboard-links start' to start the daemon."
fi
