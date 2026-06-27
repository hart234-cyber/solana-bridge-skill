# Security Policy

## Scope

This repository contains markdown skill instructions, examples, a shell installer, and validation scripts. It does not run a service, store secrets, or require API keys.

Security-sensitive areas:

- `install.sh`
- `.github/workflows/validate.yml`
- `tests/validate.sh`
- Generated code patterns documented under `skill/`

## Reporting Issues

Please open a GitHub issue with:

- Affected file.
- Steps to reproduce.
- Expected behavior.
- Actual behavior.
- Any suggested fix.

Do not include private keys, seed phrases, RPC credentials, or user data in reports.

## Installer Safety

The installer only copies files from `skill/` into a target directory named `solana-bridge-skill`. It refuses empty, root, home, current-directory, and mismatched target names.
