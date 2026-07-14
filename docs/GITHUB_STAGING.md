# GitHub staging and publishing

The product name is **Motion Shell**. The recommended repository slug is `motion-shell-wayland` so GitHub search and clone URLs remain distinct from the unrelated project already using Motion-Shell.

## Prepared repository identity

- Default branch: `main`
- Product: `Motion Shell`
- Suggested repository: `motion-shell-wayland`
- Executable: `motion-shell`
- Dart package: `motion_shell`
- Runtime and XDG namespace: `motion-shell`
- Initial release line: `0.3.0`

## One-command publishing helper

The repository includes a guarded helper. It defaults to a private repository and refuses to publish a dirty working tree:

```bash
./scripts/publish-github.sh YOUR_GITHUB_USER
```

To publish publicly:

```bash
./scripts/publish-github.sh YOUR_GITHUB_USER public
```

It uses an authenticated GitHub CLI session when available. Without `gh`, it prepares the SSH remote and prints the remaining manual command.

## Create the GitHub repository

Create an empty repository named `motion-shell-wayland`. Do not initialize it with a README, license, or `.gitignore`; those files are already committed here.

Then connect and publish this local repository:

```bash
git remote add origin git@github.com:YOUR_GITHUB_USER/motion-shell-wayland.git
git push -u origin main
```

HTTPS works as well:

```bash
git remote add origin https://github.com/YOUR_GITHUB_USER/motion-shell-wayland.git
git push -u origin main
```

When GitHub CLI is installed and authenticated, repository creation and publishing can be done in one command:

```bash
gh repo create motion-shell-wayland \
  --public \
  --source=. \
  --remote=origin \
  --push \
  --description "A Material 3 Expressive desktop shell for Wayland and Hyprland."
```

Use `--private` instead of `--public` while staging privately.

## Recommended repository settings

After the first push:

1. Enable Issues and Discussions only when they will be actively monitored.
2. Enable private vulnerability reporting and GitHub security advisories.
3. Add a `main` branch ruleset requiring the `linux` CI job and one approving review.
4. Block force pushes and branch deletion on `main`.
5. Enable Dependabot security updates.
6. Add repository topics: `flutter`, `hyprland`, `wayland`, `material-design`, `linux-desktop`, and `desktop-shell`.
7. Set the description to: **A Material 3 Expressive desktop shell for Wayland and Hyprland.**

## First staging milestone

The first GitHub milestone should remain a prototype-foundation milestone. Do not advertise production readiness until CI has run on the published repository and target-machine acceptance has covered startup, layer-shell placement, audio routing, missing services, keyboard traversal, and crash recovery.
