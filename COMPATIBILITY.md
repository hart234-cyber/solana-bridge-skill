# Compatibility Notes

This skill targets frontend code that uses the current Solana JavaScript split:

| Area | Default |
|---|---|
| Direct RPC reads and subscriptions | `@solana/web3.js` v2 |
| Address values in generated bridge types | `Address` from `@solana/web3.js` |
| Large integer account fields | native `bigint` |
| Anchor client method calls | `@coral-xyz/anchor` v0.30+ |
| Anchor account arguments requiring v1 classes | `@solana/web3.js-v1` alias |
| Token extension helpers | `@solana/spl-token` |
| React integration | React 18+ / Next.js App Router |

## Web3.js v2 Boundary

Use v2 primitives for:

- `createSolanaRpc`
- `createSolanaRpcSubscriptions`
- `address`
- `Address`
- `getProgramDerivedAddress`
- codec helpers re-exported from `@solana/web3.js`

Do not import v1 classes from `@solana/web3.js` when the project is using the v2 package.

## Anchor Compatibility Boundary

Anchor client flows may still require v1-compatible `Connection`, `PublicKey`, and `SystemProgram` values. This repo documents that through an aliased dependency:

```bash
npm install @solana/web3.js-v1@npm:@solana/web3.js@^1.95.0
```

Keep those imports at the Anchor boundary. Do not leak them into direct RPC helpers.

## Token-2022 Layouts

Prefer stable helpers from `@solana/spl-token` when they exist. Use manual byte decoders only when a helper is unavailable or a layout-level decoder is requested.

Manual decoders must document:

- Base account size.
- Extension header size.
- Extension type id.
- Field order.
- Optional pubkey representation.
- What auxiliary accounts are required but unavailable from the supplied IDL.
