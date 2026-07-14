# Technical architecture

## Selected process model: hybrid

Motion uses one shared Flutter codebase and binary with multiple surface entry modes, plus a headless state/integration service.

- **Resident processes:** `motion-state` and the system bar.
- **On-demand isolated processes:** launcher, quick settings, notifications, search, overview, OSD, and settings.
- **Shared source and behavior:** theme, tokens, models, widgets, adapters, logging language, and IPC protocol.

### Why not one Flutter process with every Wayland surface?

A single process reduces memory and synchronization work but makes a renderer or plugin failure capable of removing the entire desktop shell. Multi-window Flutter/Linux and layer-shell lifecycle also become tightly coupled.

### Why not one application per repository target?

Fully separate apps maximize isolation but duplicate build/deployment configuration and increase drift. The selected binary keeps code and packaging coherent while process instances remain independently restartable.

## Repository structure

```text
bin/                         headless state service
lib/app/                     app composition and controller
lib/core/ipc/                local protocol client
lib/core/models/             stable domain snapshots
lib/core/motion/             shared motion tokens
lib/core/platform/           safe process and layer-shell abstractions
lib/core/theme/              dynamic color and Material theme
lib/integrations/apps/       XDG desktop application discovery
lib/integrations/hyprland/   event and command sockets
lib/integrations/system/     network/audio/brightness/power/session adapters
lib/surfaces/                shell surface UIs
lib/widgets/                 shared desktop-adapted Material widgets
scripts/                     bootstrap, build, install, doctor
systemd/                     user service lifecycle
config/                      Hyprland, portals, environment, GTK
test/                        domain and widget tests
docs/                        product, design, integration, audits, roadmap
```

A later monorepo extraction can split `design_system`, `linux_services`, `hyprland`, and individual apps without changing public interfaces.

## State management

The prototype deliberately uses `ChangeNotifier` as a small presentation state boundary. It is built into Flutter, easy to inspect, and sufficient for a single immutable `SystemSnapshot` plus theme preferences. Integration logic remains outside widgets.

The state service is the source of truth when connected. Surfaces use optimistic updates for high-frequency controls and reconcile with subsequent snapshots. If the service is absent, the controller invokes the same adapters locally and exposes fallback mode.

## IPC

- Transport: Unix-domain socket under `$XDG_RUNTIME_DIR/motion-shell/state.sock`.
- Permissions: parent `0700`, socket `0600`.
- Framing: one UTF-8 JSON object per line.
- Requests: `{id, method, params}`.
- Responses: `{id, result}` or `{id, error}`.
- Events: `{event: "snapshot", data: {...}}`.
- Validation: method allow-list, typed parameter conversion, bounded local trust, malformed-message rejection.

Future versions add protocol version negotiation, message size limits, request cancellation, and peer credential checks.

## Integration boundaries

### Hyprland

`HyprlandClient` connects directly to `.socket2.sock` for events and `.socket.sock` for short synchronous commands. Connections are opened only for a request and promptly half-closed so an unclosed control socket cannot stall the compositor.

### System services

`SystemControls` exposes domain methods. The vertical slice uses maintained command interfaces (`nmcli`, `bluetoothctl`, `wpctl`, `brightnessctl`, `powerprofilesctl`) behind `SafeProcessRunner`. Arguments are passed as arrays, not interpolated shell text. The service treats missing commands as unavailable states.

D-Bus adapters are planned for long-lived state and signal subscriptions; the UI contract will not change.

### Layer shell

`LayerSurfaceHost` isolates `wayland_layer_shell`. The plugin is initialized before `runApp`, with size, layer, anchors, margins, keyboard mode, and exclusive zone chosen by surface kind. Unsupported systems or initialization failure fall back to a normal window for development and recovery.

## Persistence

- Runtime state: Unix socket and memory only.
- Preferences: atomic JSON under `$XDG_STATE_HOME/motion-shell/preferences.json` in the foundation.
- Theme cache: planned under `$XDG_CACHE_HOME/motion-shell/theme/` with wallpaper fingerprint and schema version.
- Logs: systemd journal for services; bounded diagnostic export planned.

Corrupt preference files are replaced with defaults after parsing failure. Writes use a temporary file and rename.

## Startup and shutdown

1. A UWSM-managed Hyprland session activates `graphical-session.target`.
2. `motion-shell.target` starts the state service and bar.
3. The service creates its private runtime socket, polls initial integrations, and subscribes to Hyprland events.
4. The bar connects, subscribes, and renders. If it crashes, systemd restarts it without restarting the state service.
5. On-demand surfaces are launched by `uwsm app -- motion-shell --surface=...`.
6. Session shutdown stops the graphical target and all bound shell units in order.

## Error handling

- Process calls time out and return structured failures.
- Controls retain or restore previous stable state on failure.
- Missing commands map to unavailable, not error, when absence is expected.
- Malformed desktop entries and notifications are ignored or represented safely.
- Layer-shell failure opens a regular window.
- Socket disconnects leave the current snapshot visible and enable local fallback on the next launch.
- Wallpaper failure uses a documented fallback seed.

## Logging

The service writes concise tagged messages to stderr for journald. Production logging will use structured fields: subsystem, operation, duration, result class, service availability, and redacted error. Notification bodies, filenames, app arguments, and user content are not logged by default.

## Testing strategy

- Pure unit tests for event parsing, snapshots, command validation, palette fallback, and desktop-entry sanitation.
- Widget tests for quick-setting states, semantic toggles, focus traversal, responsive navigation, and empty/error states.
- Integration tests on a nested Wayland compositor or disposable Hyprland VM.
- Missing-service matrix by masking units and removing commands from `PATH`.
- Crash recovery tests with `systemctl --user kill`.
- Visual regression capture for canonical light/dark surface states.

## Packaging and deployment

The current path is a user-local release bundle and compiled Dart service installed under `~/.local/lib/motion-shell`, with a wrapper in `~/.local/bin`. A production package should be a signed CachyOS/Arch package that installs immutable files under `/usr/lib` and user units under `/usr/lib/systemd/user`, leaving only configuration and cache in the home directory.
