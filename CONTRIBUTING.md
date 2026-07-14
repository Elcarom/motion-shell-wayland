# Contributing to Motion Shell

Motion Shell is an early-stage Flutter desktop-shell project for Wayland and Hyprland. Contributions should strengthen the product as one coherent Material 3 Expressive environment rather than add isolated widgets or theming fragments.

## Before opening a change

1. Read `docs/PRODUCT.md`, `docs/DESIGN_SYSTEM.md`, and `docs/ARCHITECTURE.md`.
2. Check `docs/M3E_COMPONENT_AUDIT.md` before introducing or replacing a visual component.
3. Prefer official Flutter Material widgets when they are semantically correct. Keep external expressive packages behind a `Motion*` abstraction.
4. Keep Linux integration out of widgets. Add or extend a typed service under `lib/integrations/`.
5. Do not interpolate untrusted values into shell commands or implement authentication in Flutter.

## Development checks

On CachyOS or another supported Linux development machine:

```bash
./scripts/prepare-linux-runner.sh
fvm flutter pub get
dart format --output=none --set-exit-if-changed lib bin test
fvm flutter analyze
fvm flutter test
fvm flutter build linux --debug
python3 scripts/static-validate.py
```

The full release gate is:

```bash
./scripts/build-release.sh
```

## Commit and pull-request guidance

Use focused commits with imperative summaries, for example:

```text
Add endpoint-specific microphone gain control
Fix Hyprland event-socket reconnection
Document expressive navigation audit
```

A pull request should describe:

- The user problem and intended behavior
- Material component and state decisions
- Linux or Hyprland integration implications
- Keyboard, focus, semantics, and reduced-motion behavior
- Failure and unavailable states
- Tests performed and screenshots for visual changes

Do not include generated build outputs, credentials, machine-specific paths, or vendored Flutter SDK files.
