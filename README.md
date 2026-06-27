# solana-bridge-skill

`solana-bridge-skill` is a Solana AI Kit skill for generating the frontend bridge layer around Anchor programs.

It focuses on the work that usually sits between a finished Solana program and a usable web app: typed IDL models, PDA helpers, account fetchers, subscriptions, Token-2022 layout handling, Anchor error maps, and React hooks.

The skill defaults to the `@solana/web3.js` v2 functional stack for direct RPC work and documents the narrow v1 compatibility bridge still needed by Anchor client flows.

## Problem

After a Solana program is written, the frontend still needs to translate the raw IDL and account layouts into safe application code. That handoff has several common failure modes:

- IDL integer types can be mapped unsafely.
- Anchor account filters often forget the 8-byte discriminator.
- PDA derivation code can lose seed order or mix address types at the Anchor boundary.
- Token-2022 extensions require layout-aware parsing.
- Anchor custom errors need readable frontend messages.
- Web3.js v1 and v2 imports are frequently mixed in incompatible ways.
- Subscriptions need cleanup paths to avoid leaking listeners.

This repository turns those recurring tasks into focused skill modules with explicit rules, examples, and validation checks.

## Scope

| Task | Skill file | Output |
|---|---|---|
| Map Anchor IDL accounts and types | `skill/parsing-idl.md` | `Address`, `bigint`, custom types, enums, error maps |
| Derive PDA accounts | `skill/pda-derivation.md` | Seed-aware helpers with address and bump output |
| Decode Token-2022 layout data | `skill/parsing-idl.md` | Browser-safe extension parsers |
| Fetch program accounts | `skill/state-fetching.md` | `createSolanaRpc`, `address`, `memcmp` filters |
| Subscribe to account updates | `skill/state-fetching.md` | WebSocket helpers with cleanup |
| Build React program context | `skill/react-hooks.md` | `AnchorProgramProvider`, `useAnchorProgram` |
| Build transaction hooks | `skill/react-hooks.md` | Hooks with pending, success, error, and reset state |
| Review generated bridge code | `skill/validation.md` | Final checklist for imports, assumptions, errors, and cleanup |

## Repository Structure

```text
solana-bridge-skill/
├── .editorconfig
├── .github/workflows/validate.yml
├── examples/
│   ├── expected-profile-bridge.md
│   ├── pda-transaction-hook.md
│   ├── sample-anchor-idl.json
│   └── token2022-transfer-hook.md
├── skill/
│   ├── SKILL.md
│   ├── parsing-idl.md
│   ├── pda-derivation.md
│   ├── react-hooks.md
│   ├── state-fetching.md
│   └── validation.md
├── tests/
│   └── validate.sh
├── CHANGELOG.md
├── COMPATIBILITY.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── SECURITY.md
├── SUBMISSION.md
└── install.sh
```

## Installation

```bash
git clone https://github.com/hart234-cyber/solana-bridge-skill
cd solana-bridge-skill
./install.sh
```

By default, the installer copies `skill/` into:

```text
../../skills/solana-bridge-skill
```

Use a custom Solana AI Kit skills path when needed:

```bash
./install.sh /path/to/solana-ai-kit/skills/solana-bridge-skill
```

The installer refuses unsafe targets and only installs into a directory named `solana-bridge-skill`.

## Usage

After installation, use prompts like:

```text
Look at my idl.json and generate TypeScript interfaces for all account types.

Build a React provider and custom hook for this Anchor program.

My mint uses Token-2022 transfer hooks. Write the extension decoder.

Derive the UserProfile PDA from my IDL and wire it into the updateProfile hook.

Fetch all UserProfile accounts for this authority using Web3.js v2.

I got custom program error 0x1774. Map it using the IDL errors.
```

The entry point is `skill/SKILL.md`. It routes each task to a focused submodule, then uses `skill/validation.md` as a final review checklist.

## Design Rules

- Load only the submodule needed for the current task.
- Do not invent accounts, seeds, discriminators, fields, or extension layouts.
- Preserve PDA seed order from the IDL and return bump values when derivation exposes them.
- Use Web3.js v2 for direct RPC reads, filters, subscriptions, and transaction-message composition.
- Keep Anchor v1 compatibility isolated to the documented `@solana/web3.js-v1` alias path.
- Map large integer types to `bigint`.
- Map Anchor option values to `T | null`.
- Avoid Node-only APIs in browser examples unless a polyfill is explicitly required.
- Expose cleanup functions for subscriptions and effect lifecycles.
- Surface readable transaction errors when the IDL provides error metadata.

## Quality Checks

Run:

```bash
bash tests/validate.sh
```

The validator checks:

- Required repository files.
- `SKILL.md` metadata and route links.
- Stale placeholders.
- Shell syntax.
- JSON syntax when `jq` is available.
- Compatibility notes.
- Example IDL presence.
- PDA and Token-2022 scenario examples.
- A temporary install of the skill files.

The same check runs in GitHub Actions through `.github/workflows/validate.yml`.

## Examples

- `examples/sample-anchor-idl.json` contains a compact Anchor IDL with accounts, custom types, PDA seeds, instruction args, and errors.
- `examples/expected-profile-bridge.md` shows the expected output shape for that IDL.
- `examples/pda-transaction-hook.md` shows PDA derivation and Anchor boundary conversion.
- `examples/token2022-transfer-hook.md` shows transfer hook parsing and extra-account-meta handling.

These files are intentionally small. They give maintainers a quick way to inspect the skill's assumptions without reading every module first.

## Fit for Solana AI Kit

This skill follows the kit shape:

- `skill/SKILL.md` entry point.
- Focused markdown submodules.
- Progressive loading.
- Local installer.
- MIT license.
- No runtime service, API key, database, binary, or generated dependency tree.
- CI-backed repository checks.

For reviewers, `SUBMISSION.md` contains the short project brief and review command.

`COMPATIBILITY.md` documents the Web3.js v2, Anchor, and Token-2022 boundaries used by the skill.

## License

MIT. See `LICENSE`.
