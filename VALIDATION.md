# Validation record

## Checks completed in the authoring container

- All shell scripts pass `bash -n`.
- The preview renderer passes Python bytecode compilation.
- YAML files parse successfully.
- Dart files pass a lexical delimiter/comment/string balance scan.
- Desktop-entry, systemd, and Hypr configuration assets are present and deployment paths are internally consistent.
- Three non-empty 1600×1000 PNG previews and a 2560×1440 wallpaper asset were rendered.
- The archive contains no generated build directory, credentials, or user-specific paths.
- Superseded branding and namespaces are absent from tracked text and paths.
- GitHub workflow, issue templates, pull-request template, Dependabot configuration, contribution policy, and security policy are present.

## Checks encoded but not executable in this container

The container does not include Flutter, Dart, GTK development packages, Hyprland, a Wayland compositor, systemd user session, Arch package tooling, or outbound DNS. Therefore `dart format`, `flutter analyze`, `flutter test`, `flutter build linux`, live layer-shell launch, and real service-control tests could not be truthfully executed here.

`scripts/build-release.sh` and `.github/workflows/ci.yml` deliberately fail the build on formatting drift, analyzer errors, test failures, Linux build errors, or state-service compilation errors. The first target-machine step is to run that gate before installation.

## Target-machine acceptance sequence

```bash
./scripts/bootstrap-cachyos.sh
./scripts/build-release.sh
./scripts/install-user.sh
./scripts/doctor.sh
```

Then follow `docs/DEMO.md`, inspect `journalctl --user -u motion-state -u motion-bar`, and record startup time, RSS, idle CPU, frame timing, multi-monitor placement, keyboard traversal, Orca output, and missing-service behavior.
