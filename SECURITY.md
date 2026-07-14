# Security policy

Motion Shell is a desktop-shell prototype and is not yet recommended as the sole security boundary for a production workstation.

## Reporting a vulnerability

Do not open a public issue for a vulnerability involving authentication, privilege escalation, command execution, IPC validation, desktop-entry parsing, notification metadata, lock/session behavior, or secret exposure.

Until a private GitHub security-advisory channel is configured, contact the repository owner privately and include:

- A concise description of the issue
- Affected commit or version
- Reproduction steps
- Expected impact
- A suggested mitigation, when available

## Security principles

- Motion Shell never stores user passwords.
- Authentication and locking are delegated to established Linux components.
- Privileged operations use polkit or service APIs.
- Process calls use separated executable arguments and timeouts.
- IPC messages and desktop metadata are treated as untrusted input.
- The shell must not run as root.
