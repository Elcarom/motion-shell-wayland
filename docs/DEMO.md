# Concise evaluation script

## Setup

1. Start a UWSM-managed Hyprland session on CachyOS.
2. Run `scripts/doctor.sh` and confirm core integrations.
3. Start `motion-shell.target` or run the showcase surface during development.

## Five-minute demo

1. **Ambient system:** Point out the single grouped system bar, active space/app, clock, privacy/status cluster, and lack of Waybar-style module boxes.
2. **Control center:** Press `Super+A`. Toggle Wi-Fi or Bluetooth, select a different output and input endpoint, adjust and mute each one independently, move brightness, change power profile, switch dark mode, and show an unavailable state.
3. **Dynamic color:** Launch Settings → Appearance, select a different wallpaper in the integrated build, and show synchronized light/dark tonal roles across bar and overlay.
4. **Launcher:** Press `Super+Space`, type an app name, navigate with arrows, launch it, and explain desktop-entry sanitation and `uwsm app` handoff.
5. **Notifications:** Press `Super+N`, act on and dismiss a notification, enable DND, then clear history.
6. **Spaces:** Press `Super+W`, compare active, occupied, and empty spaces, then activate another workspace.
7. **Search:** Press `Super+S` and show mixed app, window, setting, calculator, folder, and action hierarchy.
8. **OSD:** Use media/brightness keys in the integrated vertical slice and confirm a nonfocus-stealing overlay.
9. **Recovery:** Stop `motion-state.service`, reopen quick settings, show fallback mode, then restart the service and show reconnection in Diagnostics.
10. **Audit:** Increase text scale, use keyboard-only navigation, enable reduced motion, and show light/dark previews.

## Pass criteria

- Every primary surface looks related without relying on the same card repeated everywhere.
- Controls communicate selected, loading, disabled, unavailable, and error states.
- No shell action requires a terminal for the core workflow.
- A failed integration does not remove unrelated shell surfaces.
- The build, analyzer, tests, release bundle, and user services are green on the target system.
