---
name: solana-bridge-skill
description: Generate Solana frontend bridge code from Anchor 0.30+ IDLs, Token-2022 account layouts, and React apps using Web3.js v2 with an explicit Anchor compatibility bridge.
version: 0.2.0
license: MIT
tags:
  - solana
  - anchor
  - web3js-v2
  - token-2022
  - pda
  - react
  - frontend
---

# Solana Core-to-Extensions Bridge Skill

This skill covers the frontend bridge layer for Solana programs: Anchor IDL types, PDA derivation, Token-2022 layouts, account fetching, subscriptions, React providers, and transaction hooks. It uses `@solana/web3.js` v2 for direct RPC work and isolates the Anchor client compatibility bridge where v1-compatible types are still required.

## When To Use This Skill

Use this skill when a project has an Anchor IDL, Solana account layout, Token-2022 mint, or React/Next.js client and needs typed frontend code around the onchain program.

Common triggers:

- "Convert this Anchor IDL to TypeScript types."
- "Fetch all accounts for this program by authority."
- "Build a provider and hooks for this Anchor program."
- "Derive the PDA accounts from this IDL."
- "Decode this Token-2022 transfer hook / metadata extension."
- "Turn these custom Anchor errors into readable frontend messages."
- "Modernize this Solana frontend away from deprecated web3.js v1 APIs."

## Progressive Routing

When the user requests type conversions, state subscription pipelines, or client interaction wrappers, parse **only** the single specific submodule markdown file linked below. Do NOT load all files simultaneously.

- **Anchor IDL & Token-2022 Extension Layout Mapping**
  - *Use case*: Converting Anchor schemas into typed interfaces, decoding custom types, configuring Token-2022 extension structures, mapping error arrays.
  - *Path Link*: `./parsing-idl.md`

- **Modern Web3.js v2 State Fetching & RPC Streaming**
  - *Use case*: Implementing `createSolanaRpc`, querying program accounts with optimized memcmp filters, setting up WebSocket event subscriptions and real-time account listeners.
  - *Path Link*: `./state-fetching.md`

- **PDA Derivation & Account Resolution**
  - *Use case*: Deriving PDAs from Anchor IDL seed metadata, resolving account addresses for hooks, validating dynamic seed requirements.
  - *Path Link*: `./pda-derivation.md`

- **React Context Architecture & Interaction Hooks**
  - *Use case*: Building global program providers, handling async state mutations, executing modern atomic transaction workflows with proper loading and error states.
  - *Path Link*: `./react-hooks.md`

- **Bridge Output Quality Gate**
  - *Use case*: Reviewing generated bridge code before final answer, checking version compatibility, browser safety, error handling, and user-facing deliverables.
  - *Path Link*: `./validation.md`

## Procedure

1. Identify the user's requested bridge task and load only the matching submodule. Load multiple submodules only when the request crosses boundaries, such as PDA derivation plus React hook generation.
2. Inspect any user-provided IDL, account layout, code, or package versions before generating code.
3. If required layout details, accounts, seeds, or instruction arguments are missing, ask for verification instead of inventing them.
4. Generate strict TypeScript code suitable for a React/Next.js project.
5. Before finalizing, load `./validation.md` and apply the relevant checklist to the generated output.
6. In the final response, list files/functions produced, required dependencies, and any assumptions that still need user confirmation.

## Generation Rules

1. **Strict Web3.js v2 Default**: For all direct RPC, address handling, account fetching, subscriptions, and transaction message composition, use the functional Web3.js v2 pattern with `address()`, `pipe()`, `createSolanaRpc()`, and `createTransactionMessage()`. Do not emit legacy `new PublicKey()`, `new Transaction()`, or `new Keypair()` for modern v2 code.

2. **Anchor Compatibility Exception**: Anchor 0.30 clients still require v1-compatible wallet and connection types in some React flows. When generating Anchor `.methods` hooks, use the explicit aliased package `@solana/web3.js-v1` exactly as described in `./react-hooks.md`, and isolate that bridge from all direct RPC logic.

3. **Zero Guesswork**: If an instruction account, PDA seed, field layout parameter, discriminator, or Token-2022 extension requirement is absent from the user-provided source, immediately stop generation and request verification from the user. Never invent mock fields or placeholder account addresses.

4. **PDA Derivation Discipline**: Derive PDAs only from IDL seed metadata, source code, or explicit user input. Preserve seed order and return bump values when available.

5. **Token-2022 Alignment**: When handling mints or token accounts, check for transfer hooks, metadata pointers, transfer fees, permanent delegates, close authorities, and extra account metas. Output auxiliary account fetching code when the layout requires it.

6. **Real Transactions Only**: Never output placeholder strings or mock signatures for transaction execution. For v2 transaction builders, compose real transactions using `pipe()`, `setTransactionMessageFeePayerSigner()`, `setTransactionMessageLifetimeUsingBlockhash()`, and `signAndSendTransactionMessageWithSigners()`. For Anchor method hooks, call `.rpc()` on the real method chain.

7. **Anchor Version Awareness**: Target `@coral-xyz/anchor` v0.30+ exclusively. Do not use `Provider.env()`, hardcoded local wallets, or examples that only work in Node when the user is building a browser frontend.

8. **Browser-Safe By Default**: Frontend examples must avoid Node-only APIs such as `Buffer` unless the user's app already provides a browser polyfill. Prefer `Uint8Array`, `atob`, `TextEncoder`, and codecs re-exported from `@solana/web3.js`.

9. **Auditable Output**: Generated code must include named exports, explicit imports, typed arguments, meaningful error surfaces, and cleanup functions for subscriptions.
