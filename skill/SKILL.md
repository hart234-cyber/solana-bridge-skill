# Solana Modern 2026 Core-to-Extensions Bridge Skill

This skill transforms any coding agent (Claude Code / Codex) into an expert frontend systems architect specializing in the modern Solana development stack. It provides absolute context, strict rules, and layout structures to bridge Anchor 0.30+ IDLs and Token-2022 Extensions with web clients using the modern `@solana/web3.js` v2 ecosystem.

## Capabilities & Progressive Routing

When the user requests type conversions, state subscription pipelines, or client interaction wrappers, parse **only** the single specific submodule markdown file linked below. Do NOT load all files simultaneously.

- **Anchor IDL & Token-2022 Extension Layout Mapping**
  - *Use case*: Converting Anchor schemas into typed interfaces, decoding custom types, configuring Token-2022 extension structures, mapping error arrays.
  - *Path Link*: `./parsing-idl.md`

- **Modern Web3.js v2 State Fetching & RPC Streaming**
  - *Use case*: Implementing `createSolanaRpc`, querying program accounts with optimized memcmp filters, setting up WebSocket event subscriptions and real-time account listeners.
  - *Path Link*: `./state-fetching.md`

- **React Context Architecture & Interaction Hooks**
  - *Use case*: Building global program providers, handling async state mutations, executing modern atomic transaction workflows with proper loading and error states.
  - *Path Link*: `./react-hooks.md`

## Immutable AI Behavior Rules

1. **Strict Web3.js v2 Stack**: Never emit legacy v1 syntax. Do not generate `new Connection()`, `new PublicKey()`, `new Transaction()`, or `new Keypair()`. Explicitly enforce the functional Web3.js v2 pattern using `address()`, `pipe()`, `createSolanaRpc()`, and `createTransactionMessage()`.

2. **Zero Guesswork**: If an instruction account or field layout parameter is absent from the user-provided IDL schema, immediately stop generation and request verification from the user. Never invent mock fields or placeholder account addresses.

3. **Token-2022 Alignment**: When handling mints or token accounts, check the IDL for transfer hooks, metadata pointers, or close authority extensions, and automatically output code to fetch their corresponding auxiliary accounts using `@solana/spl-token`.

4. **Real Transactions Only**: Never output placeholder strings or mock signatures for transaction execution. Always compose real transactions using `pipe()`, `setTransactionMessageFeePayerSigner()`, `setTransactionMessageLifetimeUsingBlockhash()`, and `signAndSendTransactionMessageWithSigners()`.

5. **Anchor Version Awareness**: Target `@coral-xyz/anchor` v0.30+ exclusively. Do not use deprecated `Program` constructor signatures or `Provider.env()`.
