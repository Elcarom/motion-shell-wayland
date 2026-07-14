# Validation audits

## Material component audit

| Area | Result | Notes |
|---|---|---|
| Theme roles | Pass | Components use `ColorScheme` and component themes; fallback seed is documented |
| Buttons | Pass | Filled, tonal, text, and icon buttons match action hierarchy |
| Navigation | Pass | Navigation rail and bar adapt to width |
| Sliders | Pass | Official slider with semantic percent labels |
| Toggles | Pass | Switches for preferences; custom quick tile only for shell-specific compound control |
| Segmented controls | Pass | Theme and power profiles use `SegmentedButton` |
| Cards | Pass with watch | Filled cards are used for grouped system material; avoid expanding card use indiscriminately |
| Search | Pass | Official `SearchBar`; provider result behavior remains to be integrated |
| Notifications | Partial | Material structure implemented; live D-Bus daemon pending |
| Menus | Pending | App actions and device/output menus are staged |
| Motion | Partial | Shared duration/curve tokens and switchers exist; full container transforms pending |
| State coverage | Partial-pass | Core enabled, disabled, loading, unavailable, and error states exist; device-specific errors need test matrix |
| Responsive behavior | Pass foundation | Grids and settings navigation adapt; multi-monitor scaling needs integration tests |

### Documented custom widgets

`QuickSettingTile` is custom because Flutter has no official system quick-setting tile combining icon, title, secondary state, compound toggle semantics, loading state, and desktop-adaptive width. It uses Material, InkWell, theme roles, semantic toggle state, and shared shape/motion tokens.

`SurfaceFrame` is a structural wrapper for Wayland overlay surfaces. It uses Material elevation, shape, and roles rather than custom painting.

## Accessibility audit

Implemented:

- Minimum 48 px primary interactive targets.
- Material focus handling and reading-order traversal group.
- Tooltips on compact icon actions.
- Toggle semantics for quick-setting tiles.
- Percent semantic labels for sliders.
- Non-color icons and text for status.
- Explicit disabled and unavailable states.
- Adaptive scrolling and unclamped text scale.
- Reduced-motion preference and shared duration resolver.
- Escape/back behavior supplied by Flutter routes/sheets where used.

Needs validation on target:

- Orca semantics for every layer surface.
- Visible focus contrast under every wallpaper-derived scheme.
- Full keyboard grid navigation and launcher app actions.
- High-contrast scheme variants.
- RTL layout and long localized strings.
- 200% text scale on the bar and compact overlays.
- Switch access and touch screen behavior.

## Desktop integration audit

| Scenario | Foundation behavior |
|---|---|
| Wi-Fi hardware/service missing | Tile is unavailable |
| Bluetooth absent | Tile is unavailable |
| No battery | Battery UI omitted |
| Brightness unsupported | Slider remains available only after adapter result; final UI will disable explicitly |
| D-Bus/service unavailable | Command adapter or local fallback; error surfaced |
| Hyprland IPC disconnects | Event stream reconnects; last state remains while unavailable |
| Monitor added/removed | Events supported; per-monitor spawning pending |
| Wallpaper missing | Fallback seed |
| App icon missing | Initial/avatar fallback |
| Malformed desktop entry | Ignored |
| Malformed local IPC | Ignored and service remains alive |
| Command timeout | Structured failure, optimistic state rolled back |
| Surface crash | systemd restart for resident units; other processes isolated |
| Settings corrupt | Defaults and atomic rewrite |
| Theme service absent | Local theme generation |

## Performance assessment

Design targets for a production target machine:

- Bar first frame under 350 ms after process start.
- On-demand overlay first frame under 450 ms warm and 700 ms cold.
- State service idle CPU effectively zero outside event handling and the eight-second low-frequency capability refresh.
- Bar RSS under 130 MB; transient surfaces released after close.
- No wallpaper decode on the UI thread after first-run bootstrap; production extraction moves to an isolate/service.
- 60 fps minimum and display-refresh-rate target during surface transitions.

Current foundation strengths:

- Hyprland is event-driven.
- System polling is centralized and low frequency.
- Hidden surfaces are separate processes, not retained widget trees.
- Wallpaper sample is bounded to 128 px on its longest sampled axis.
- Process execution is asynchronous and timed.
- Snapshots are immutable and small.

Current risks:

- Pure-Dart wallpaper decoding currently runs during initialization and should move off the UI isolate.
- Each Flutter overlay has process startup and memory cost.
- CLI polling should become D-Bus signal subscriptions for network, power, and audio.
- App discovery should cache desktop files and monitor directories.
- Live thumbnails can become GPU/CPU expensive and need strict rate and resolution limits.

## Security audit

- The shell never runs as root.
- Passwords are never collected or stored.
- Process arguments are separated and `runInShell` is false.
- Screenshot geometry is captured as a process result and passed as one argument.
- Power/session actions use logind/systemd policy paths.
- The local socket is user-private.
- Desktop entries are treated as display metadata; launching uses `gtk-launch` by desktop ID instead of executing the untrusted `Exec` line directly.
- Privileged actions remain behind polkit.

Pending hardening:

- Verify Unix peer credentials.
- Bound IPC line size and notification payloads.
- Add explicit notification image limits and safe image decoding.
- Use package-installed immutable service binaries rather than home directory executables.
- Add sandbox policy review for the state service after D-Bus adapters are finalized.

## Known limitations

1. The current execution environment used to prepare this repository does not contain Flutter, Dart, Hyprland, Wayland, or Arch package tooling, so the included build/analyze/test pipeline could not be executed here.
2. The notification surface is fed by prototype data; it does not yet own the freedesktop notification D-Bus service.
3. Window thumbnails and drag/move actions are conceptual in the overview.
4. One layer surface is compositor-selected; multi-monitor instance management is pending.
5. OSD launch/coalescing from hardware keys is not yet connected to the state service.
6. Brightness, battery, microphone, VPN, keyboard layout, night light, and media state need fuller adapters.
7. Theme preference persistence and cross-process snapshot updates are implemented; wallpaper fingerprint invalidation and animated revision handoff are pending.
8. The layer-shell package is isolated but still an external plugin with required runner changes.
9. GTK/Qt theme synchronization is static in the prototype and cannot make third-party widgets Material.
10. Onboarding, reset, and recovery navigation are documented but not fully surfaced.
