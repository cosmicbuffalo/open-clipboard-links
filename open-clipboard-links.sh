#!/bin/bash

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/open-clipboard-links"
CONFIG_PATH="$CONFIG_DIR/config.sh"

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "Error: $CONFIG_PATH not found. Run install.sh, or copy config.sh.example there and customize it." >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$CONFIG_PATH"

LAST_URL=""
PREV_APP=""

get_front_app() {
  osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'
}

# Function to check if a given app is one we should ignore
should_ignore() {
  local app="$1"
  local ignored
  for ignored in "${IGNORED_APPS[@]}"; do
    [[ "$app" == "$ignored" ]] && return 0
  done
  return 1
}

# Pick browser based on URL
open_url() {
  local url="$1"

  if [[ "$url" == *"github.com"* ]]; then
    local prefix
    for prefix in "${GITHUB_EXCLUDE_PREFIXES[@]}"; do
      if [[ "$url" == *"$prefix"* ]]; then
        echo "Opening in $DEFAULT_BROWSER: $url"
        open -a "$DEFAULT_BROWSER" "$url"
        return
      fi
    done
    echo "Opening in $GITHUB_BROWSER: $url"
    open -a "$GITHUB_BROWSER" "$url"
  else
    echo "Opening in $DEFAULT_BROWSER: $url"
    open -a "$DEFAULT_BROWSER" "$url"
  fi
}

while true; do
  CLIP=$(pbpaste)
  CURRENT_APP=$(get_front_app)

  if [[ "$CLIP" =~ ^https?:// ]] && [[ "$CLIP" != "$LAST_URL" ]]; then
    if should_ignore "$PREV_APP"; then
      echo "ignored app was focused at copy time ($PREV_APP). Skipping: $CLIP"
    else
      open_url "$CLIP"
    fi
    LAST_URL="$CLIP"
  fi

  PREV_APP="$CURRENT_APP"
  sleep "$POLL_INTERVAL"
done
