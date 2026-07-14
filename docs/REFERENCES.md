# Authoritative references and dependency review

Accessed for the prototype foundation on 2026-07-14.

## Design and Flutter

- Material 3: https://m3.material.io/
- Flutter Material library: https://api.flutter.dev/flutter/material/
- Flutter `ThemeData`: https://api.flutter.dev/flutter/material/ThemeData-class.html
- Flutter M3E umbrella/status issue: https://github.com/flutter/flutter/issues/168813
- Flutter M3E slider proposal: https://github.com/flutter/flutter/issues/184947
- Updated official Material 3 slider migration: https://docs.flutter.dev/release/breaking-changes/updated-material-3-slider
- Material Color Utilities: https://pub.dev/packages/material_color_utilities

The implementation prioritizes Flutter's official Material widgets, `ThemeData`, `ColorScheme`, and component themes. Flutter's complete M3E component set is not yet available in the core Material library; package-backed components and desktop-specific adaptations are therefore isolated and classified explicitly in the audit.

## Layer shell and expressive packages

- `wayland_layer_shell` 1.0.1: https://pub.dev/packages/wayland_layer_shell
- API documentation and required Linux runner change: https://pub.dev/documentation/wayland_layer_shell/latest/
- `m3e_design` 0.2.1: https://pub.dev/packages/m3e_design
- `m3e_buttons` 0.0.4: https://pub.dev/packages/m3e_buttons
- `icon_button_m3e` 0.2.1: https://pub.dev/packages/icon_button_m3e
- `loading_indicator_m3e` 0.1.1: https://pub.dev/packages/loading_indicator_m3e

`wayland_layer_shell` is wrapped behind `LayerSurfaceHost` because it modifies the Linux runner and has a narrow Wayland-only contract. Expressive packages are wrapped behind Motion-owned widgets and are adopted per component, not treated as a blanket design-system replacement. Current Flutter Material components remain where they provide stronger semantics or where no expressive implementation has passed desktop validation. The slider does not depend on a third-party package. `MotionSlider` adapts Flutter's official current slider to the documented expressive default anatomy while keeping the unavailable XS–XL, inset-icon, and vertical capabilities explicit.

## Audio control

- WirePlumber `wpctl`: https://pipewire.pages.freedesktop.org/wireplumber/tools/wpctl.html

The prototype uses separate sink and source catalogs plus `wpctl set-default`, `set-volume`, and `set-mute`. The adapter is centralized and scheduled for replacement by event-driven PipeWire/WirePlumber integration.

## Hyprland and session integration

- Hyprland IPC: https://wiki.hypr.land/IPC/
- UWSM/systemd startup: https://wiki.hypr.land/Useful-Utilities/Systemd-start/
- Hypridle: https://wiki.hypr.land/Hypr-Ecosystem/hypridle/
- Hyprlock: https://wiki.hypr.land/Hypr-Ecosystem/hyprlock/
- Hyprpaper: https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/
- XDG desktop portal for Hyprland: https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/

## Current Arch/CachyOS package sources

- Arch Linux packages: https://archlinux.org/packages/
- gtk-layer-shell: https://archlinux.org/packages/extra/x86_64/gtk-layer-shell/
- xdg-desktop-portal-hyprland: https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-hyprland/
- hyprpolkitagent: https://archlinux.org/packages/extra/x86_64/hyprpolkitagent/
- power-profiles-daemon: https://archlinux.org/packages/extra/x86_64/power-profiles-daemon/
- UPower: https://archlinux.org/packages/extra/x86_64/upower/
- FVM: https://archlinux.org/packages/extra/x86_64/fvm/
- adw-gtk-theme: https://archlinux.org/packages/extra/any/adw-gtk-theme/
- qt5ct and qt6ct: https://archlinux.org/packages/extra/x86_64/qt5ct/ and https://archlinux.org/packages/extra/x86_64/qt6ct/
