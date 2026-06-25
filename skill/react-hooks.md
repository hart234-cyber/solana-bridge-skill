# Submodule: React Context Architecture & Interaction Hooks

This document mandates structural patterns for generating global UI integration points and custom event handlers tailored to Web3.js v2 and Anchor 0.30+.

## Core Rules for the AI Agent

1. **Use the Hybrid Connection Bridge**: `@coral-xyz/anchor` v0.30 is internally coupled to `@solana/web3.js` v1. To safely combine Anchor with the modern v2 stack, instantiate a legacy v1 `Connection` object **exclusively** for the Anchor `AnchorProvider`. Use `createSolanaRpc` from Web3.js v2 for all direct RPC calls, state fetching, and WebSocket subscriptions outside of Anchor.
2. **Correct Component Imports**: For all hooks executing transactions through Anchor's `.methods` chain, always import `PublicKey` and `SystemProgram` from `@solana/web3.js-v1`. These classes do not exist in v2 — importing them from `@solana/web3.js` v2 throws fatal TypeScript compilation errors because v2 replaced them with functional primitives.
3. **Wrap RPC Sessions Globally**: Maintain a single unified `Program` reference in a React Context Provider. Never re-initialize the provider inside individual components.
4. **Expose Granular Mutation States**: Every transaction hook must return `isPending`, `txSignature`, and `error` so the UI can render loading spinners, success links, and error messages independently.
5. **Guard Against Disconnected Wallet**: Always check `if (!wallet)` before initializing an `AnchorProvider`. Return `null` from the provider's `useMemo` if the wallet is not connected.
6. **Real Transactions Only**: Never use placeholder strings or mock signatures. Always call `.rpc()` on the Anchor method chain for real transaction submission.
7. **Use useMemo for Stability**: Wrap `Program` and `AnchorProvider` initialization in `useMemo` to prevent unnecessary re-renders and re-initializations.

## Required Packages

```bash
npm install @coral-xyz/anchor@^0.30.0 @solana/wallet-adapter-react @solana/web3.js@^2.0.0
# Also install v1 as an aliased dependency for the Anchor bridge:
npm install @solana/web3.js-v1@npm:@solana/web3.js@^1.95.0
```

## Reference Blueprint: Unified Anchor Program Provider (Hybrid Bridge)

When a user requests a global context to manage their Anchor program instance across the app. Note the dual-import pattern — `Connection` from v1 is used **only** to satisfy the Anchor client internally:

```typescript
import { createContext, useContext, useMemo, ReactNode } from 'react';
import { useAnchorWallet } from '@solana/wallet-adapter-react';
import { AnchorProvider, Program, Idl } from '@coral-xyz/anchor';
// v1 Connection — used ONLY as a bridge for the Anchor client internals
import { Connection } from '@solana/web3.js-v1';
// v2 Address — used for all modern public key references outside Anchor
import { Address } from '@solana/web3.js';

interface AnchorProgramContextType {
  program: Program | null;
  rpcEndpoint: string;
}

const AnchorProgramContext = createContext<AnchorProgramContextType | null>(null);

export function AnchorProgramProvider({
  children,
  idl,
  programId,
  rpcEndpoint,
}: {
  children: ReactNode;
  idl: Idl;
  programId: string; // Accept as string; Anchor resolves internally
  rpcEndpoint: string;
}) {
  const wallet = useAnchorWallet();

  const program = useMemo(() => {
    if (!wallet) return null;

    // Bridge: Build a v1 Connection specifically for the Anchor client.
    // All other RPC calls in the app use createSolanaRpc from Web3.js v2.
    const v1Connection = new Connection(rpcEndpoint, 'confirmed');

    const provider = new AnchorProvider(v1Connection, wallet, {
      commitment: 'confirmed',
      preflightCommitment: 'confirmed',
    });

    return new Program(idl, programId, provider);
  }, [wallet, idl, programId, rpcEndpoint]);

  return (
    <AnchorProgramContext.Provider value={{ program, rpcEndpoint }}>
      {children}
    </AnchorProgramContext.Provider>
  );
}

export function useAnchorProgram(): AnchorProgramContextType {
  const context = useContext(AnchorProgramContext);
  if (!context) {
    throw new Error('useAnchorProgram must be used inside an <AnchorProgramProvider>');
  }
  return context;
}
```

## Reference Blueprint: Instruction Execution Hook

When generating a custom hook to send a specific Anchor instruction (e.g., `updateProfile`):

```typescript
import { useState, useCallback } from 'react';
import { useAnchorProgram } from './AnchorProgramProvider';
import { parseProgramError } from './parsing-idl';

// CRITICAL: Import from the v1 alias package — Anchor's .accounts() mapping
// requires legacy v1 PublicKey and SystemProgram types internally.
// Importing these from @solana/web3.js v2 will throw fatal TypeScript errors.
import { PublicKey, SystemProgram } from '@solana/web3.js-v1';

interface UpdateProfileArgs {
  username: string;
  profileAddress: PublicKey;
  authorityAddress: PublicKey;
}

interface UseUpdateProfileResult {
  updateProfile: (args: UpdateProfileArgs) => Promise<string | null>;
  isPending: boolean;
  txSignature: string | null;
  error: string | null;
  reset: () => void;
}

export function useUpdateProfile(): UseUpdateProfileResult {
  const { program } = useAnchorProgram();
  const [isPending, setIsPending] = useState(false);
  const [txSignature, setTxSignature] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const reset = useCallback(() => {
    setTxSignature(null);
    setError(null);
  }, []);

  const updateProfile = useCallback(
    async ({ username, profileAddress, authorityAddress }: UpdateProfileArgs): Promise<string | null> => {
      if (!program) {
        setError('Wallet not connected. Please connect your wallet to continue.');
        return null;
      }

      setIsPending(true);
      setError(null);
      setTxSignature(null);

      try {
        // Calls the real Anchor instruction — replace method name with your IDL instruction name
        const sig = await program.methods
          .updateProfile(username)
          .accounts({
            userProfile: profileAddress,
            authority: authorityAddress,
            systemProgram: SystemProgram.programId,
          })
          .rpc();

        setTxSignature(sig);
        setIsPending(false);
        return sig;
      } catch (err: unknown) {
        const readable = parseProgramError(err);
        setError(readable);
        setIsPending(false);
        return null;
      }
    },
    [program]
  );

  return { updateProfile, isPending, txSignature, error, reset };
}
```

## Reference Blueprint: Account Subscription Hook (Real-time UI Updates)

When a component needs to display live onchain state that updates automatically:

```typescript
import { useEffect, useState, useRef } from 'react';
import { watchAccountChanges } from './state-fetching';
import type { UserProfileState } from './parsing-idl';

/**
 * Subscribes to a UserProfile account and keeps local state in sync.
 * Automatically cleans up the WebSocket subscription on unmount.
 */
export function useLiveUserProfile(
  wsUrl: string,
  profileAddress: string | null,
  decode: (data: Uint8Array) => UserProfileState
) {
  const [profile, setProfile] = useState<UserProfileState | null>(null);
  const cleanupRef = useRef<(() => void) | null>(null);

  useEffect(() => {
    if (!profileAddress) return;

    let cancelled = false;

    watchAccountChanges(wsUrl, profileAddress, (rawData) => {
      if (!cancelled) {
        try {
          setProfile(decode(rawData));
        } catch {
          console.error('Failed to decode account update');
        }
      }
    }).then((cleanup) => {
      if (cancelled) {
        cleanup();
      } else {
        cleanupRef.current = cleanup;
      }
    });

    return () => {
      cancelled = true;
      cleanupRef.current?.();
      cleanupRef.current = null;
    };
  }, [wsUrl, profileAddress]);

  return profile;
}
```

## Usage Example: Wiring the Provider in Next.js App Router

Add this to your `app/layout.tsx` or root providers file. Pass the RPC endpoint explicitly — the provider uses it internally to create the v1 Connection bridge for Anchor:

```typescript
import { AnchorProgramProvider } from '@/hooks/AnchorProgramProvider';
import myIdl from '@/idl/my_program.json';

const PROGRAM_ID = 'YOUR_PROGRAM_ID_HERE'; // string — no PublicKey needed
const RPC_ENDPOINT = process.env.NEXT_PUBLIC_RPC_URL ?? 'https://api.mainnet-beta.solana.com';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <WalletContextProvider> {/* Your existing wallet adapter setup */}
      <AnchorProgramProvider
        idl={myIdl}
        programId={PROGRAM_ID}
        rpcEndpoint={RPC_ENDPOINT}
      >
        {children}
      </AnchorProgramProvider>
    </WalletContextProvider>
  );
}
```

> **Note for the AI agent**: Use `createSolanaRpc(rpcEndpoint)` from `@solana/web3.js` v2 for all direct RPC calls (account fetching, WebSocket subscriptions) outside of Anchor. The `AnchorProgramProvider` handles the v1 bridge internally and transparently.
