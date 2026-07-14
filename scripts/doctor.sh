#!/usr/bin/env bash
set -u

status=0
check() {
  local label=$1 command=$2
  if command -v "$command" >/dev/null 2>&1; then
    printf '✓ %-28s %s\n' "$label" "$(command -v "$command")"
  else
    printf '✗ %-28s missing: %s\n' "$label" "$command"
    status=1
  fi
}

check 'Hyprland control' hyprctl
check 'NetworkManager control' nmcli
check 'PipeWire control' wpctl
check 'Bluetooth control' bluetoothctl
check 'Brightness control' brightnessctl
check 'Power profiles' powerprofilesctl
check 'Screenshot capture' grim
check 'Region selection' slurp
check 'Screen recording' wf-recorder
check 'Flutter version manager' fvm

printf '\nEnvironment:\n'
printf '  XDG_RUNTIME_DIR=%s\n' "${XDG_RUNTIME_DIR:-unset}"
printf '  HYPRLAND_INSTANCE_SIGNATURE=%s\n' "${HYPRLAND_INSTANCE_SIGNATURE:-unset}"
printf '  WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-unset}"

systemctl --user --no-pager --full status motion-shell.target motion-state.service motion-bar.service 2>/dev/null || true
exit "$status"
