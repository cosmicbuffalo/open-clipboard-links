# open-clipboard-links

Watches the clipboard for URLs and opens them automatically, skipping the
trigger if the URL was likely copied from a browser (Chrome/Safari) or Slack
(to avoid re-opening links you just copied from those apps).

## Install

One-liner (clones to `~/open-clipboard-links` and installs):

```sh
curl -fsSL https://raw.githubusercontent.com/cosmicbuffalo/open-clipboard-links/main/bootstrap.sh | bash
```

Or, if you've already cloned the repo:

```sh
./install.sh
```

This installs a launchd LaunchAgent (starts on login, restarts on crash) and
symlinks the `open-clipboard-links` CLI into `~/.local/bin` (make sure that's
on your `PATH`). It also creates config at
`${XDG_CONFIG_HOME:-~/.config}/open-clipboard-links/config.sh` from
`config.sh.example` if it doesn't already exist.

## Config

Personal/environment-specific behavior lives in
`${XDG_CONFIG_HOME:-~/.config}/open-clipboard-links/config.sh` (not part of
this repo). Edit it directly, or re-copy from `config.sh.example`:

- `IGNORED_APPS` — apps that suppress auto-opening when frontmost at copy time
- `POLL_INTERVAL` — clipboard poll interval in seconds
- `GITHUB_BROWSER` / `DEFAULT_BROWSER` — which browser opens github.com links
  vs. everything else
- `GITHUB_EXCLUDE_PREFIXES` — github.com URL prefixes (e.g. an org) that
  should fall back to `DEFAULT_BROWSER` instead of `GITHUB_BROWSER`

After editing `config.sh`, run `open-clipboard-links restart`.

## Usage

```sh
open-clipboard-links start     # start the daemon
open-clipboard-links stop      # stop the daemon
open-clipboard-links restart   # restart (e.g. after editing the script)
open-clipboard-links status    # check whether it's running
open-clipboard-links logs      # tail stdout/stderr logs
open-clipboard-links help      # show usage
```

## How it works

`open-clipboard-links.sh` polls the clipboard every 0.25s. When it sees a new
URL, it checks which app was frontmost on the *previous* poll tick (i.e.
roughly when you copied) and skips opening it if that app is in the ignore
list. Otherwise it opens the URL, routing `github.com` links to
`GITHUB_BROWSER` (except paths matching `GITHUB_EXCLUDE_PREFIXES`, which fall
back to `DEFAULT_BROWSER`) and everything else to `DEFAULT_BROWSER`.
