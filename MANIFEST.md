# Deliverable manifest

This index maps the requested deliverables to concrete repository assets.

| # | Deliverable | Location |
|---:|---|---|
| 1 | Product concept and name | `README.md`, `docs/PRODUCT.md` |
| 2 | Design principles | `docs/PRODUCT.md`, `docs/DESIGN_SYSTEM.md` |
| 3 | Complete shell surface map | `docs/PRODUCT.md` |
| 4 | User journeys | `docs/PRODUCT.md` |
| 5 | Visual design system | `docs/DESIGN_SYSTEM.md`, `lib/core/theme/` |
| 6 | Dynamic color architecture | `docs/DESIGN_SYSTEM.md`, `lib/core/theme/dynamic_color_service.dart`, `bin/motion_service.dart` |
| 7 | Motion system | `docs/DESIGN_SYSTEM.md`, `lib/core/motion/motion_transitions.dart` |
| 8 | Flutter architecture | `docs/ARCHITECTURE.md` |
| 9 | Repository structure | `docs/ARCHITECTURE.md` |
| 10 | Core source code | `lib/`, `bin/` |
| 11 | Hyprland integration | `lib/integrations/hyprland/`, `config/hypr/` |
| 12 | Linux service integrations | `lib/integrations/system/`, `docs/INTEGRATION.md` |
| 13 | CachyOS bootstrap | `scripts/bootstrap-cachyos.sh` |
| 14 | Development setup | `README.md`, `scripts/prepare-linux-runner.sh` |
| 15 | Build instructions | `README.md`, `scripts/build-release.sh` |
| 16 | Deployment scripts | `scripts/install-user.sh`, `scripts/uninstall-user.sh` |
| 17 | systemd user units | `systemd/` |
| 18 | Hyprland configuration | `config/hypr/motion.conf` |
| 19 | Default application suite | `docs/APP_SUITE.md` |
| 20 | GTK/Qt/icons/cursor/fonts | `docs/INTEGRATION.md`, `config/environment/`, `config/gtk-*` |
| 21 | Test suite | `test/`, `.github/workflows/ci.yml` |
| 22 | Material audit | `docs/AUDITS.md`, `docs/M3E_COMPONENT_AUDIT.md` |
| 23 | Accessibility audit | `docs/AUDITS.md` |
| 24 | Performance assessment | `docs/AUDITS.md` |
| 25 | Known limitations | `docs/AUDITS.md`, `VALIDATION.md` |
| 26 | Prioritized roadmap | `docs/ROADMAP.md` |
| 27 | Rendered previews | `assets/previews/` |
| 28 | Demo script | `docs/DEMO.md` |
| 29 | GitHub staging and contribution workflow | `docs/GITHUB_STAGING.md`, `scripts/publish-github.sh`, `CONTRIBUTING.md`, `.github/` |

## Functional prototype boundary

The vertical slice has real state/control adapters for Wi-Fi radio, Bluetooth power, independent PipeWire/WirePlumber input and output device selection, mute, and volume, brightness, power profiles, screenshots, session actions, Hyprland workspace/active-window/screencast events, application discovery, cross-process appearance state, and layer-shell placement. Surfaces that depend on owning a desktop-wide protocol or compositor capture—especially notifications and live window thumbnails—are represented with production-oriented interfaces and explicit staged work rather than unsafe mock ownership.
