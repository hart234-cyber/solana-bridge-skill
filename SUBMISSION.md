# Submission Brief

## Project

`solana-bridge-skill`

## Summary

This skill covers the frontend bridge layer around Anchor programs: IDL type mapping, PDA derivation, account fetchers, subscriptions, Token-2022 layout handling, readable Anchor errors, and React hooks.

## Why It Matters

Many Solana apps lose time after the program is written because the frontend bridge is still fragile. Common mistakes include unsafe integer mappings, missing Anchor discriminators in filters, PDA seed-order mistakes, incompatible Web3.js imports, incomplete Token-2022 parsing, and subscriptions without cleanup.

This skill captures those details in focused modules that can be loaded only when needed.

## What Is Included

- `skill/SKILL.md` entry point with route metadata.
- Focused modules for IDL parsing, PDA derivation, state fetching, React hooks, and output validation.
- Example Anchor IDL and expected bridge output.
- Local validation script.
- GitHub Actions workflow.
- Compatibility notes for Web3.js v2, Anchor, and Token-2022 boundaries.
- Safer installer.
- MIT license.

## Review Commands

```bash
bash tests/validate.sh
```

## Repository

`https://github.com/hart234-cyber/solana-bridge-skill`
