# Desktop and service integration

## Hyprland

Motion uses supported IPC sockets for event-driven workspace, active-window, monitor, keyboard-layout, screencast, and window lifecycle updates. Commands are centralized in `HyprlandClient`. The shell configuration starts user services through systemd and launches transient apps with UWSM, avoiding an unmanaged process tree under the compositor.

The prototype does not poll `hyprctl` for frequent state. Window and monitor snapshots will use JSON control-socket requests after relevant events.

## Layer shell and monitors

The bar reserves its height with an automatic exclusive zone. Overlays use the overlay layer and appropriate keyboard mode. The current foundation creates one compositor-selected surface; production multi-monitor support will enumerate monitors, start one bar instance per monitor, and route overlays to the focused monitor.

## Portals

- `xdg-desktop-portal-hyprland`: screenshot and screencast.
- `xdg-desktop-portal-gtk`: file chooser and app chooser fallback.
- `GTK_USE_PORTAL=1`: encourages portal use by GTK applications.
- PipeWire/WirePlumber provide the media stream used by screencast portals.

Portal startup depends on a correctly exported Wayland and desktop environment. The supplied Hyprland config imports those variables into systemd and D-Bus activation.

## Networking

NetworkManager is the supported backend. The vertical slice reads and changes radio state through `nmcli`; a D-Bus adapter will add access-point lists, connection progress, captive portal state, VPNs, metered state, and secret-agent handoff without parsing command text.

No password is stored by Motion. Network secrets remain with NetworkManager and the keyring.

## Bluetooth

BlueZ is the backend. The prototype exposes adapter availability and power through `bluetoothctl`. The full adapter will subscribe to `org.bluez` object changes and delegate pairing confirmation through a dedicated agent surface without storing credentials.

## Audio and media

PipeWire and WirePlumber are required. `wpctl` supports separate sink/source discovery, default endpoint selection, mute, and endpoint volume in the vertical slice. Later native integration will replace polling with object events and add profiles, ports, per-app streams, and microphone privacy state. MPRIS media controls use the standard player interfaces and remain independent of audio routing.

## Power and battery

- UPower: batteries, line power, percentage, state, time estimates.
- power-profiles-daemon: saver, balanced, performance where hardware supports them.
- logind: lock, suspend, hibernate, reboot, and poweroff with policy enforcement.

A desktop without a battery simply omits the battery indicator. Unsupported hibernation is disabled with explanatory text.

## Brightness and night light

`brightnessctl` is the vertical-slice adapter. Devices without a controllable backlight show unavailable. `hyprsunset` is the preferred night-light implementation; the shell will manage temperature and schedule through its supported control interface.

## Notifications

The visual notification model, history surface, urgency, actions, progress form, DND, and malformed-data boundaries are represented. Production integration requires a small notification broker that owns `org.freedesktop.Notifications`, validates all metadata, persists bounded history, and forwards sanitized models to the state service. Only one daemon may own that name, so existing daemons must be disabled during installation.

## Clipboard

`wl-clipboard` plus `cliphist` is the recommended backend. A future search source reads only user-requested history and never logs clipboard content. Sensitive MIME types and applications can be excluded.

## Lock, idle, and authentication

- `hypridle` controls idle policy.
- `hyprlock` performs secure lock rendering and PAM authentication.
- logind controls session lock and sleep.
- `hyprpolkitagent` handles privileged actions.
- GNOME Keyring/libsecret stores application secrets.

Motion may generate colors and wallpaper assets for `hyprlock`, but Flutter does not collect or verify passwords.

## GTK consistency

Reliably controlled:

- Roboto font, Papirus icons, Bibata cursor.
- Light/dark preference and compatible adw-gtk3 theme.
- Portal file chooser.
- Launch environment and MIME defaults.

Not fully controlled:

- App-specific custom CSS, client-side decoration layouts, embedded web content, and applications that ignore GTK settings.

## Qt consistency

`QT_QPA_PLATFORMTHEME=qt6ct` provides a user-controlled Qt theme bridge. A production theme exporter will map Material roles to a restrained Qt palette and configure icons/fonts. Qt applications will not become Material components; the goal is coherent color, typography, icons, and dialogs rather than false equivalence.

## XWayland and custom-rendered apps

Cursor, fonts, icon lookup, and some environment preferences carry through. Native toolkit controls, decorations, and custom canvases may remain visually different. Motion documents these limits rather than injecting fragile per-app CSS or binary patches.

## Default applications and MIME

The installer will eventually set defaults with `xdg-mime` only after explicit onboarding choices. The prototype recommends Firefox, Nautilus, GNOME Text Editor, Loupe, Celluloid, Amberol, File Roller, Calculator, and Evince and leaves existing user defaults untouched.
