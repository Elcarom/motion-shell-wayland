# Recommended basic application suite

Selection favors native Wayland behavior, portal support, maintenance, keyboard usability, fast startup, and the ability to inherit common GTK/Qt settings. The shell does not pretend that every application is Material.

| Role | Choice | Why | Tradeoff |
|---|---|---|---|
| Terminal | WezTerm | Wayland, GPU rendering, strong keyboard model, configurable font and chrome | Custom-rendered UI is not Material |
| File manager | Nautilus | Excellent portals, GVfs, search, removable media, maintained GTK4/libadwaita | Header patterns remain GNOME |
| Text editor | GNOME Text Editor | Fast, GTK4, adaptive, simple daily editing | Not a full IDE |
| Image viewer | Loupe | Modern Wayland GTK4 viewer | GNOME visual language |
| Video player | Celluloid | MPV reliability with GTK integration | Settings are not fully adaptive |
| Audio player | Amberol | Focused, modern GTK4 local playback | Limited library management |
| Archive manager | File Roller | Broad format support and Nautilus integration | Older GTK patterns in places |
| Calculator | GNOME Calculator | Keyboard-friendly, capable, maintained | GNOME styling |
| PDF viewer | Evince | Reliable, accessible, broad desktop integration | Older UI than newer Papers; conservative choice |
| Screenshot | Grim + Slurp + portal | Native Wayland, scriptable, portal-compatible | Shell must provide polished confirmation UI |
| Screen recorder | wf-recorder + portal | Native Wayland and PipeWire-friendly | Full controls need shell wrapper |
| System monitor | GNOME System Monitor | Stable process/resource view | Visual mismatch accepted |
| Disk usage | Baobab | Clear hierarchy and maintained GTK app | GNOME styling |
| Bluetooth management | Motion quick settings + Blueman fallback | Shell covers daily actions; Blueman handles edge cases | Blueman is GTK3 and visually older |
| Network management | Motion quick settings + nm-connection-editor fallback | Shell covers daily state; established editor handles complex profiles | Editor mismatch is controlled |
| Package management | `pacman`, CachyOS tools, optional Octopi | Reliable native package path | No Material-quality graphical manager selected |
| Clipboard history | cliphist + wl-clipboard | Native Wayland and lightweight | Motion UI still required |
| Authentication agent | hyprpolkitagent | Hyprland-maintained and systemd-integrated | Qt/QML visual mismatch accepted for security |
| Polkit | polkit + hyprpolkitagent | Standard least-privilege path | None |
| Secrets | GNOME Keyring + libsecret | Broad app compatibility | PAM setup needed for TTY login |
| File search | FSearch initially | Fast indexed local search | GTK visual mismatch; future direct search provider |
| Font viewer | GNOME Font Viewer | Simple and maintained | GNOME styling |
| Character map | Gucharmap | Complete Unicode coverage | Older GTK presentation |
| Updates | `pacman-contrib`, CachyOS update tooling | Distribution-native | Shell update UI is deferred |
| Browser | Firefox | Native Wayland, portal support, already present | Web chrome is its own design language |
| Defaults | XDG MIME tools + Motion onboarding | Standards-based and explicit | Requires careful onboarding UX |

## Where a mismatch is accepted

Security agents, advanced connection editors, package management, and diagnostics favor established capability over a custom clone. Motion frames their launch, uses portals and shared fonts/icons, and clearly crosses into an external application.

## Focused replacements worth building

- Notification broker and history.
- Search provider UI.
- Wallpaper/appearance picker.
- Quick settings with independent output and input selection.
- Clipboard search surface.

These are shell-native flows where consistency and integration justify focused Flutter code. A file manager, browser, terminal, and package manager are intentionally out of scope.
