# Changelog

## 0.3.0 — Motion Shell rebrand and GitHub staging

- Applied the **Motion Shell** product identity across source, documentation, tests, services, desktop entries, deployment paths, and user-facing strings.
- Renamed the Dart package to `motion_shell` and all internal branded abstractions to the `Motion*` namespace.
- Renamed the motion-token type to `MotionTransitions` to avoid the ambiguous `MotionMotion` construction.
- Renamed the executable, state service, systemd units, Hyprland include, desktop entries, runtime socket, and XDG directories to the `motion-shell` namespace.
- Added GitHub contribution, security, issue, pull-request, dependency-update, and staging documentation.
- Prepared a clean `main` branch with an initial Git commit suitable for publishing as `motion-shell-wayland`.

## 0.2.1 — Artifact packaging correction

- Rebuilt the distributed archives from the current repository rather than the stale pre-audio staging tree.
- Verified that the ZIP contains `audio_device.dart`, `wpctl_parser.dart`, the Motion M3E wrappers, audio tests, and the revised quick-settings surface.
- Regenerated the quick-settings PNG under a cache-safe filename that visibly shows separate output and input device selectors and volume sliders.
- Added archive-content checks to the validation record.

## 0.2.0 — M3E component and audio control pass

- Replaced standard shell action buttons with Motion wrappers around M3E buttons.
- Replaced direct icon buttons with M3E icon-button wrappers.
- Replaced segmented controls with expressive connected choice groups.
- Replaced value controls with an official-Flutter `Slider` adaptation behind `MotionSlider`, using the current expressive 16 dp gapped track and narrow handle. It remains provisional until Flutter exposes XS–XL presets, inset-track icons, and native vertical orientation.
- Rebuilt quick-setting tiles on an expressive toggle-button implementation.
- Added expressive short-duration loading state.
- Removed the legacy Linux fade-up page transition and arbitrary tooltip shape override.
- Added separate output and input device catalogs, selection, volume, and mute controls.
- Added WirePlumber status parsing and endpoint-specific IPC methods.
- Added audio parser and model regression tests.
- Reclassified navigation, search, cards/lists, dialogs, sheets, and OSD progress honestly as current M3 or pending expressive work.
- Audited every interactive widget family and reclassified official Material 3 components honestly instead of promoting them to M3E by association.
- Disabled endpoint controls while audio availability is loading, unavailable, or in error.
