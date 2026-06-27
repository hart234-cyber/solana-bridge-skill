# Contributing

Thanks for improving `solana-bridge-skill`. This repo is intentionally small, but the bar for changes is high because these files guide code generation for Solana projects.

## Design Principles

- Keep the skill progressive. Add focused submodules only when they prevent large, unrelated context from being loaded.
- Prefer precise rules over broad advice. The skill should state what to generate, what to avoid, and when to ask for missing source data.
- Do not add binaries, generated dependency trees, or network-dependent install steps.
- Keep examples browser-safe unless the document explicitly targets Node.js tooling.
- Preserve the Web3.js v2 default and isolate any Anchor v1 alias usage to the compatibility bridge described in the docs.

## Local Checks

Run:

```bash
bash tests/validate.sh
```

The validator checks required files, frontmatter, route links, stale placeholders, shell syntax, and a temp install.

## Pull Request Checklist

- Update `README.md` if the skill shape, install path, or supported use cases change.
- Update `skill/SKILL.md` if routing changes.
- Add or update examples when adding a new major behavior.
- Run `bash tests/validate.sh`.
- Keep the license MIT-compatible.
