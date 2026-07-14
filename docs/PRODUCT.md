# Product definition

## Concept

**Motion Shell** is an Android-inspired, desktop-native shell for Hyprland. Its premise is that Material 3 Expressive is not a color palette or a collection of pills; it is a hierarchy, state, motion, and interaction system. Motion therefore presents the desktop as a sequence of purposeful Material surfaces rather than a conventional panel plus unrelated utilities.

Tagline: **Material motion, desktop scale.**

## Product vision

A user should be able to sit at a fresh CachyOS machine and immediately understand where system state lives, how to launch or find work, how spaces relate, and how to recover from missing hardware or services. The experience should feel authored by one product team even when underlying Linux applications cannot share the shell's exact rendering.

## Design principles

1. **One system, many surfaces.** Every surface shares roles, tokens, language, states, motion, diagnostics, and keyboard behavior.
2. **State before decoration.** Selected, loading, unavailable, error, privacy, and urgency states are designed before visual flourish.
3. **Spatial clarity.** Motion preserves where content came from and where it goes; workspace navigation is a map of intent rather than a wall of tiny screenshots.
4. **Desktop scale without desktop cruft.** Larger canvases gain hierarchy and adaptive navigation, not smaller targets or denser toolbars.
5. **Graceful incompleteness.** Missing batteries, radios, commands, services, icons, or wallpaper files produce honest unavailable or fallback states.
6. **Secure delegation.** Authentication, locking, privileges, secrets, and session control remain with established Linux components.
7. **Standards over shell tricks.** Portals, XDG files, systemd user services, logind, Hyprland IPC, and stable service interfaces are preferred.

## Experience goals

- Reach any primary shell flow in one shortcut and one understandable surface.
- Make current workspace, active app, privacy activity, connectivity, time, and alerts glanceable without a module grid.
- Make quick settings usable by pointer, keyboard, and touch-sized targets.
- Make search the fastest path to applications, windows, settings, files, calculations, and safe system actions.
- Make errors actionable without exposing raw Linux complexity by default.

## Surface inventory

| Surface | Process class | Primary role |
|---|---|---|
| System bar | Resident layer surface | Ambient state and entry points |
| Quick settings | On-demand overlay | High-frequency system controls |
| Launcher | On-demand overlay | App discovery, recents, pins, actions |
| Notifications | On-demand overlay plus popup lane | History, actions, urgency, DND |
| Search | On-demand overlay | Unified local result hierarchy |
| Workspace overview | On-demand overlay | Spatial workspace and window navigation |
| OSD | Short-lived overlay | Noninterrupting feedback |
| Settings | Normal app window | Persistent shell and integration settings |
| State service | Headless user service | Shared models, integration, synchronization |
| Onboarding/recovery | Normal or overlay surface | First run, missing services, reset |
| Lock/session | Established external secure components | Authentication and power lifecycle |

## Core journeys

### Begin work

1. The bar shows the active space and ambient status.
2. `Super+Space` transforms the desktop focus into the launcher.
3. Typing filters applications immediately; arrow keys and Enter launch through `uwsm app` when available.
4. Launch feedback collapses the surface toward the selected app position.

### Change connectivity or sound

1. `Super+A` opens the control center from the bar's system cluster.
2. Tiles expose selected, disabled, loading, error, and unavailable states.
3. Sliders update optimistically and reconcile with the state service.
4. A compact OSD confirms hardware-key changes without stealing focus.

### Navigate workspaces

1. `Super+W` opens the Spaces map.
2. Each workspace is a meaningful room with app identities and availability, not a literal scaled desktop.
3. The current space carries strong selection; empty spaces invite a new task.
4. Activation uses Hyprland IPC and keeps focus continuity.

### Recover from a failure

1. A failed adapter keeps the prior stable value where safe.
2. The control shows an error state and plain-language reason.
3. Diagnostics identify missing commands, services, environment variables, and process health.
4. A crashed surface restarts independently; the bar and state service are separate units.

## Initial application suite

The prototype favors adaptive GTK/libadwaita apps where their behavior is strong, a focused terminal, and established Wayland utilities. Exact Material rendering cannot be imposed on third-party applications; the shell aligns fonts, icons, cursors, portals, color preference, and launch behavior while documenting mismatches. See `APP_SUITE.md`.

## Technical constraints

- Flutter Linux embeds through GTK and layer shell requires runner initialization before the window is shown.
- Layer shell is Wayland-only and compositor-dependent.
- Hyprland provides events and commands but not a standardized thumbnail API.
- Linux desktop notifications require owning a well-known D-Bus name; only one notification daemon can do so.
- GTK, Qt, XWayland, Electron, and custom-rendered applications have different theming limits.
- Secure authentication must not be reimplemented in Flutter.

## Prototype scope

The prototype proves the product identity, shared design system, process topology, state service, primary surface structures, dynamic color, application discovery, Hyprland events, core controls, deployment, and recovery behavior.

## Explicit non-goals

- Reimplementing every system settings backend.
- Replacing NetworkManager, BlueZ, PipeWire, logind, polkit, portals, or a secure lock implementation.
- Perfect Material styling inside arbitrary third-party applications.
- Shipping an app store, full file manager, media suite, or browser.
- Depending on compositor-private screenshot hacks for production thumbnails.
