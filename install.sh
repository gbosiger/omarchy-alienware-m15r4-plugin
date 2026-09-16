#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
install -Dm755 "$root/bin/omarchy-alienware" "$HOME/.local/bin/omarchy-alienware"
install -d "$HOME/.config/omarchy/plugins/gebo.alienware"
cp -a "$root/omarchy/plugins/gebo.alienware/." "$HOME/.config/omarchy/plugins/gebo.alienware/"

printf '%s\n' "Custom files installed. Merge config/shell.json into your Omarchy shell configuration." \
  "Install the udev rule with sudo, then run: omarchy-shell shell rescanPlugins"
