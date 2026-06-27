# Submodule: Modern Web3.js v2 State Fetching & RPC Streaming

This document defines the functional patterns for requesting, filtering, and subscribing to onchain account data using the modern, high-performance `@solana/web3.js` v2 architecture.

## Core Rules

1. **Enforce Functional Composition**: Construct all RPC calls using `createSolanaRpc()`. Never use `new Connection()` from legacy web3.js v1.
2. **Use `address()` for Direct v2 RPC**: Direct Web3.js v2 public key conversions must use the `address()` helper from `@solana/web3.js`.
3. **Use `getBase58Decoder` for pubkey bytes**: When decoding raw pubkey bytes from account data, use `getBase58Decoder` from `@solana/web3.js` directly — all codecs are natively re-exported from the unified v2 core package. Never add `@solana/codecs` as a separate dependency.
4. **Implement Clean Subscription Teardown**: Always return an abort/unsubscribe function from subscription helpers to prevent memory leaks.
5. **Skip the 8-byte Anchor Discriminator**: All `memcmp` filters on Anchor program accounts must start at `offset: 8` to skip the discriminator prefix.
6. **Respect the Anchor Boundary**: When calling Anchor `program.account.*.fetch`, use v1-compatible public keys from the aliased `@solana/web3.js-v1` package. Keep that exception isolated from direct Web3.js v2 RPC code.

## Required Packages

```bash
npm install @solana/web3.js@^2.0.0 @coral-xyz/anchor@^0.30.0 @solana/spl-token
npm install @solana/web3.js-v1@npm:@solana/web3.js@^1.95.0
```

## Reference Blueprint: High-Performance Filtered Account Query

When fetching multiple accounts belonging to a specific wallet or authority:

```typescript
import { createSolanaRpc, address, Address } from '@solana/web3.js';

/**
 * Fetches all UserProfile accounts owned by a specific authority wallet.
 * Uses memcmp filter at offset 8 (skipping Anchor discriminator) to match authority address.
 */
export async function fetchUserProfiles(
  rpcUrl: string,
  programAddress: string,
  authorityWallet: string
): Promise<Array<{ address: Address; rawData: Uint8Array }>> {
  const rpc = createSolanaRpc(rpcUrl);
  const programId = address(programAddress);

  const accounts = await rpc.getProgramAccounts(programId, {
    encoding: 'base64',
    filters: [
      {
        memcmp: {
          offset: BigInt(8), // Skip 8-byte Anchor account discriminator
          bytes: authorityWallet,
          encoding: 'base58',
        },
      },
    ],
  }).send();

  return accounts.map((acc) => ({
    address: acc.address, // v2 uses acc.address — acc.pubkey is deprecated and does not exist
    // Browser-safe base64 decode — no Node.js Buffer required
    rawData: new Uint8Array(
      atob(acc.account.data as unknown as string)
        .split('')
        .map((c) => c.charCodeAt(0))
    ),
  }));
}
```

## Reference Blueprint: Single Account Fetch with Anchor

When the user has an Anchor `Program` instance and wants to fetch a single typed account:

```typescript
import { Program } from '@coral-xyz/anchor';
import { PublicKey } from '@solana/web3.js-v1';
import type { UserProfileState } from './parsing-idl';

/**
 * Fetches a single UserProfile account using the Anchor client.
 * Returns a fully typed UserProfileState or null if the account does not exist.
 */
export async function fetchUserProfile(
  program: Program,
  profileAddress: string
): Promise<UserProfileState | null> {
  try {
    const pubkey = new PublicKey(profileAddress);
    const account = await (program.account as any).userProfile.fetch(pubkey);
    return account as UserProfileState;
  } catch (err: unknown) {
    // Anchor throws when account doesn't exist — treat as null, not error
    if ((err as any)?.message?.includes('Account does not exist')) return null;
    throw err;
  }
}
```

## Reference Blueprint: Real-Time Account Subscription (WebSocket)

When the frontend needs to react to live onchain state changes without polling:

```typescript
import { createSolanaRpcSubscriptions, address } from '@solana/web3.js';

/**
 * Opens a WebSocket subscription to a specific account.
 * Calls `onUpdate` with the latest account data on every confirmed change.
 * Returns a cleanup function — always call it on component unmount to prevent leaks.
 */
export async function watchAccountChanges(
  wsUrl: string,
  accountAddress: string,
  onUpdate: (data: Uint8Array) => void
): Promise<() => void> {
  const rpcSub = createSolanaRpcSubscriptions(wsUrl);
  const target = address(accountAddress);

  const abortController = new AbortController();

  const subscription = await rpcSub
    .accountNotifications(target, { commitment: 'confirmed', encoding: 'base64' })
    .subscribe({ abortSignal: abortController.signal });

  // Process notifications asynchronously in background
  (async () => {
    try {
      for await (const notification of subscription) {
        // Browser-safe base64 decode — no Node.js Buffer required
        const base64String = notification.value.data as unknown as string;
        const rawData = new Uint8Array(
          atob(base64String).split('').map((c) => c.charCodeAt(0))
        );
        onUpdate(rawData);
      }
    } catch (err: unknown) {
      // AbortError is expected on cleanup — silence it
      if ((err as any)?.name !== 'AbortError') {
        console.error('Account subscription error:', err);
      }
    }
  })();

  // Return cleanup function to caller
  return () => abortController.abort();
}
```

## Reference Blueprint: Token-2022 Mint Account Fetch

When a user needs to fetch a Token-2022 mint and parse its extensions:

```typescript
import { createSolanaRpc, address } from '@solana/web3.js';
import { parseTransferHookExtension } from './parsing-idl';

export async function fetchToken2022Mint(rpcUrl: string, mintAddress: string) {
  const rpc = createSolanaRpc(rpcUrl);
  const mint = address(mintAddress);

  const accountInfo = await rpc.getAccountInfo(mint, { encoding: 'base64' }).send();

  if (!accountInfo.value) throw new Error(`Mint account not found: ${mintAddress}`);

  // Browser-safe base64 decode — no Node.js Buffer required
  const base64String = accountInfo.value.data as unknown as string;
  const rawData = new Uint8Array(
    atob(base64String).split('').map((c) => c.charCodeAt(0))
  );

  return {
    rawData,
    transferHook: parseTransferHookExtension(rawData),
  };
}
```
