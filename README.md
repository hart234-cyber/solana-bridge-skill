# solana-bridge-skill

A production-grade AI skill for the [Solana AI Kit](https://github.com/solanabr/solana-ai-kit) that turns any coding agent (Claude Code / Codex) into an expert Solana frontend architect.

It bridges the gap between Anchor 0.30+ smart contracts and modern React/Next.js frontends using the **Web3.js v2** functional stack — eliminating hours of manual boilerplate and preventing AI hallucinations about deprecated v1 APIs.

---

## The Problem It Solves

When a developer finishes writing a Solana program in Anchor, they receive a raw `idl.json` file. To make this usable in a frontend, they must manually:

- Map every IDL type to a TypeScript interface
- Write state fetching functions with correct `memcmp` filters
- Build React Context Providers and custom hooks
- Handle Token-2022 extensions if their mint uses them
- Parse cryptic hex error codes into readable messages

This takes **hours**, is highly error-prone, and standard AI models almost always generate **deprecated `@solana/web3.js` v1 code** that breaks in 2026 projects.

This skill fixes all of that. Install it once, and your coding agent becomes an expert in the exact modern patterns required.

---

## What It Does

| User Request | Skill Route | Output |
|---|---|---|
| "Map my IDL to TypeScript types" | `parsing-idl.md` | Typed interfaces using `Address` and `bigint` |
| "Parse Token-2022 transfer hook" | `parsing-idl.md` | Correct byte-offset decoder |
| "Fetch all accounts by authority" | `state-fetching.md` | `createSolanaRpc` + memcmp filter |
| "Subscribe to live account changes" | `state-fetching.md` | WebSocket subscription with cleanup |
| "Build a React provider for my program" | `react-hooks.md` | `AnchorProgramProvider` + `useAnchorProgram` |
| "Hook to send my updateProfile instruction" | `react-hooks.md` | Full hook with `isPending`, `txSignature`, `error` |

---

## Directory Structure

```
solana-bridge-skill/
├── README.md               # This file
├── install.sh              # Automated installer
└── skill/
    ├── SKILL.md            # Master router — entry point for the AI agent
    ├── parsing-idl.md      # IDL type mapping, error maps, Token-2022 decoders
    ├── state-fetching.md   # Web3.js v2 RPC queries, filters, subscriptions
    └── react-hooks.md      # React Context providers, transaction hooks, live updates
```

---

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/solana-bridge-skill
cd solana-bridge-skill
chmod +x install.sh
./install.sh
```

This copies the `skill/` folder into `../../skills/solana-bridge-skill` relative to the repo — the standard location for skills in the Solana AI Kit.

To install to a custom path:

```bash
./install.sh /path/to/your/solana-ai-kit/skills/solana-bridge-skill
```

---

## How to Use It

Once installed, open Claude Code inside your Solana project and try these prompts:

```
"Look at my idl.json and generate TypeScript interfaces for all account types."

"Build me a React Context Provider and custom hook to fetch all user profile accounts."

"My mint uses Token-2022 transfer hooks — write a decoder for it."

"Subscribe to live changes on this account address and update my UI automatically."

"I got error 0x1774 — what does that mean and how do I fix it?"
```

The agent will read `SKILL.md`, route to the correct submodule, and generate accurate, production-ready code without mixing in deprecated v1 patterns.

---

## Tech Stack Covered

- `@coral-xyz/anchor` v0.30+
- `@solana/web3.js` v2 (`createSolanaRpc`, `pipe`, `address`)
- `@solana/spl-token` (Token-2022 extensions)
- `@solana/wallet-adapter-react`
- React 18+ / Next.js App Router
- TypeScript strict mode

---

## No Cost, No Hosting Required

This skill is **100% local**. It runs inside Claude Code on your own machine. No API keys, no servers, no subscriptions.

---

## License

MIT — open source and ready to be merged or submoduled into the standard kit.
