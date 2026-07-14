# Prioritized roadmap

## P0 — prove the vertical slice on real CachyOS hardware

1. Run bootstrap, generate Linux runner, resolve package/API drift, and make format/analyze/test/release green.
2. Validate `wayland_layer_shell` on current Hyprland; keep a native gtk-layer-shell runner fallback branch.
3. Add UPower battery state and explicit brightness availability.
4. Replace audio polling with WirePlumber/PipeWire event integration.
5. Add NetworkManager and BlueZ D-Bus subscriptions.
6. Implement OSD coalescing and connect media/brightness keys through the state service.
7. Add theme fingerprint cache and atomic cross-process revision.
8. Measure startup, RSS, idle CPU, and animation frame timing.

## P1 — daily desktop shell

1. Notification broker owning `org.freedesktop.Notifications`, popup lane, history, grouping, actions, progress, DND, and limits.
2. Launcher favorites, recents, app actions, icon theme resolution, and launch feedback.
3. Unified search providers for apps, windows, settings, calculator, files, recents, actions, and web handoff.
4. Real Hyprland window/workspace snapshots, activation, close, move, special workspaces, and monitor routing.
5. Multi-monitor bar instances and focused-monitor overlays.
6. Settings for appearance, notifications, quick settings, audio, displays, keyboard, workspaces, power, accessibility, and diagnostics.
7. Wallpaper picker and `hyprpaper` synchronization.
8. `hyprlock` theme generator and coherent session sheet.

## P2 — refinement and ecosystem coherence

1. Thumbnail provider through portal/compositor-supported capture with strict privacy and resource limits.
2. MPRIS media cards and OSD.
3. VPN, keyboard layout, airplane/offline mode, night-light schedule, and output/device menus.
4. Clipboard search provider with exclusions and sensitivity rules.
5. First-run onboarding, dependency repair, safe reset, and diagnostic export.
6. Dynamic GTK/Qt preference exporter and lock/login palette bridge.
7. Localization, RTL, high-contrast variants, Orca validation, and automated keyboard traversal tests.
8. Signed Arch/CachyOS package, update channel, migration system, and reproducible CI image.

## P3 — optional expressive depth

1. Reevaluate `m3e_core` after API stabilization and adopt only components that improve fidelity without weakening maintainability.
2. Add spring-based container transformations where Flutter's stable Material components do not yet expose expressive behavior.
3. Add user-controlled shape/density profiles only after usability testing demonstrates value.
4. Explore touch/tablet posture and stylus affordances without compromising desktop keyboard flows.
