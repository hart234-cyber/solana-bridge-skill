# Changelog

## 0.2.0

- Added `validation.md` as a final-pass quality gate for generated bridge code.
- Added `pda-derivation.md` for IDL seed mapping and account resolution.
- Added kit-style frontmatter and clearer progressive routing to `skill/SKILL.md`.
- Documented the Web3.js v2 default and the narrow Anchor v1 alias compatibility bridge.
- Fixed option type guidance to consistently use `T | null`.
- Added custom IDL type and enum mapping guidance.
- Hardened `install.sh` against unsafe target paths.
- Added example IDL and expected bridge output artifacts.
- Added PDA transaction hook and Token-2022 transfer hook examples.
- Added compatibility notes for Web3.js v2, Anchor, and Token-2022 boundaries.
- Corrected the Transfer Hook layout blueprint to use fixed-width optional pubkey handling.
- Added local validation script and GitHub Actions workflow.

## 0.1.0

- Initial Solana Bridge Skill release.
- Added Anchor IDL parsing, Web3.js v2 state fetching, and React hook blueprints.
