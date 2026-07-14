#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo 'Run this script as your normal user; it will invoke sudo for packages.' >&2
  exit 1
fi

core_packages=(
  base-devel git cmake ninja clang pkgconf fvm rsync xdg-utils fontconfig desktop-file-utils uwsm
  gtk3 gtk-layer-shell
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  networkmanager bluez bluez-utils pipewire wireplumber pipewire-pulse
  upower power-profiles-daemon brightnessctl playerctl
  grim slurp wf-recorder wl-clipboard cliphist
  hypridle hyprlock hyprpaper hyprsunset hyprpolkitagent
  gnome-keyring libsecret polkit libnotify
  socat jq curl unzip imagemagick python-pillow python-yaml
  ttf-roboto ttf-roboto-mono noto-fonts noto-fonts-emoji
  papirus-icon-theme  adw-gtk-theme qt5ct qt6ct
)

app_packages=(
  firefox wezterm nautilus gnome-text-editor loupe celluloid amberol
  file-roller gnome-calculator evince gnome-system-monitor baobab
  blueman nm-connection-editor pavucontrol
   gnome-font-viewer gucharmap
)

sudo pacman -Syu --needed "${core_packages[@]}" "${app_packages[@]}"
sudo systemctl enable --now NetworkManager.service bluetooth.service power-profiles-daemon.service

fvm install 3.44.0
fvm use 3.44.0 --force
fvm flutter config --enable-linux-desktop

mkdir -p "$HOME/.config/environment.d" "$HOME/.config/xdg-desktop-portal"
install -m 0644 config/environment/90-motion.conf "$HOME/.config/environment.d/90-motion.conf"
install -m 0644 config/xdg-desktop-portal/hyprland-portals.conf \
  "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
install -m 0644 config/gtk-3.0/settings.ini "$HOME/.config/gtk-3.0/settings.ini"
install -m 0644 config/gtk-4.0/settings.ini "$HOME/.config/gtk-4.0/settings.ini"

systemctl --user enable --now hyprpolkitagent.service || true
systemctl --user enable --now gnome-keyring-daemon.service || true
systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-hyprland.service || true

printf '\nBootstrap complete. Run scripts/build-release.sh, then scripts/install-user.sh.\n'
