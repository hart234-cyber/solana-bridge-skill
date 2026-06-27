# Expected Bridge Output Example

This example shows the expected bridge output shape for `examples/sample-anchor-idl.json`. It is not a generated source file; it is a compact review artifact for maintainers.

## Type Mapping

```typescript
import type { Address } from '@solana/web3.js';

export type ProfileTier =
  | { kind: 'Free' }
  | { kind: 'Pro' }
  | { kind: 'Team'; fields: { seats: number } };

export interface UserProfileState {
  authority: Address;
  bump: number;
  loyaltyPoints: bigint;
  username: string;
  metadataPointer: Address | null;
  tier: ProfileTier;
}
```

## Error Map

```typescript
export const BRIDGE_PROFILE_ERRORS: Record<number, string> = {
  6000: 'InvalidUsernameLength: Username must be between 3 and 20 characters.',
  6001: 'Unauthorized: Signer does not match the stored authority.',
};
```

## Fetching Rules Demonstrated

- Use `createSolanaRpc()` and `address()` for direct v2 RPC reads.
- Use `offset: BigInt(8)` for Anchor account memcmp filters.
- Use `bigint` for `u64`.
- Use `Address | null` for Anchor option values.
- Use the aliased `@solana/web3.js-v1` package only when calling Anchor account fetches or Anchor `.methods` hooks that require v1-compatible public keys.

## Hook Rules Demonstrated

- Expose `isPending`, `txSignature`, `error`, and `reset`.
- Do not invent missing account addresses or PDA seeds.
- Call the real `program.methods.updateProfile(username).accounts(...).rpc()` chain.
- Parse custom errors through the generated error map.
