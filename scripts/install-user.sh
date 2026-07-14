#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

bundle=build/linux/x64/release/bundle
service=build/service/motion-service
[[ -x "$bundle/motion_shell" ]] || { echo 'Build release first.' >&2; exit 1; }
[[ -x "$service" ]] || { echo 'Compile the state service first.' >&2; exit 1; }

install_root="$HOME/.local/lib/motion-shell"
mkdir -p "$install_root" "$HOME/.local/bin" "$HOME/.config/systemd/user" \
  "$HOME/.config/hypr/conf.d" "$HOME/.config/hypr" \
  "$HOME/.local/share/applications" "$HOME/.local/share/motion-shell"
rsync -a --delete "$bundle/" "$install_root/app/"
install -m 0755 "$service" "$install_root/motion-service"
install -m 0644 systemd/*.service systemd/*.target "$HOME/.config/systemd/user/"
install -m 0644 config/hypr/motion.conf "$HOME/.config/hypr/conf.d/motion.conf"
install -m 0644 config/hypr/hypridle.conf "$HOME/.config/hypr/hypridle.conf"
install -m 0644 config/hypr/hyprlock.conf "$HOME/.config/hypr/hyprlock.conf"
install -m 0644 config/hypr/hyprpaper.conf "$HOME/.config/hypr/hyprpaper.conf"
install -m 0644 config/applications/*.desktop "$HOME/.local/share/applications/"
install -m 0644 assets/wallpaper.png "$HOME/.local/share/motion-shell/wallpaper.png"

cat > "$HOME/.local/bin/motion-shell" <<WRAPPER
#!/usr/bin/env bash
exec "$install_root/app/motion_shell" "\$@"
WRAPPER
chmod 0755 "$HOME/.local/bin/motion-shell"

hypr_main="$HOME/.config/hypr/hyprland.conf"
touch "$hypr_main"
source_line='source = ~/.config/hypr/conf.d/motion.conf'
grep -Fxq "$source_line" "$hypr_main" || printf '\n%s\n' "$source_line" >> "$hypr_main"

systemctl --user daemon-reload
systemctl --user enable motion-shell.target
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
systemctl --user restart hyprpaper.service hypridle.service || true
systemctl --user restart motion-shell.target || true
hyprctl reload >/dev/null 2>&1 || true

echo 'Motion Shell installed for the current user.'
