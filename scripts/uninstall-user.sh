#!/usr/bin/env bash
set -euo pipefail
systemctl --user disable --now motion-shell.target || true
rm -rf "$HOME/.local/lib/motion-shell"
rm -f "$HOME/.local/bin/motion-shell"
rm -f "$HOME/.config/systemd/user/motion-"*.service "$HOME/.config/systemd/user/motion-shell.target"
rm -f "$HOME/.config/hypr/conf.d/motion.conf"
rm -f "$HOME/.config/hypr/hypridle.conf" "$HOME/.config/hypr/hyprlock.conf" \
  "$HOME/.config/hypr/hyprpaper.conf"
rm -f "$HOME/.local/share/applications/motion-settings.desktop" \
  "$HOME/.local/share/applications/motion-launcher.desktop"
rm -rf "$HOME/.local/share/motion-shell"
systemctl --user daemon-reload
