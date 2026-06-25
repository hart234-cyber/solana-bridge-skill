# Submodule: Anchor IDL & Token-2022 Extension Layout Mapping

This document provides explicit conversion rules for translating modern Anchor 0.30+ JSON IDL files and complex Token-2022 extensions into strict TypeScript typings compatible with Web3.js v2.

## Core Rules for the AI Agent

1. **Apply Web3.js v2 Type System**: Map the Solana `pubkey` IDL type to the `Address` type from `@solana/web3.js` v2. Never use the legacy `PublicKey` class.
2. **Handle Large Integers Safely**: Convert `u64`, `i64`, `u128`, and `i128` explicitly to native JavaScript `bigint`. Never use `BN` from `@coral-xyz/anchor` in new v2 code.
3. **Map Token-2022 Extensions**: When an application requires configuration for modern token accounts, follow the structural layout mapped below.
4. **Export Error Maps**: Always extract the `errors` array from the IDL and produce a typed error lookup map for runtime error handling.
5. **Browser-Safe Decoding**: Use `getBase58Decoder` from `@solana/web3.js` directly — all codecs are natively re-exported from the unified v2 core package. Never import from `@solana/codecs` as a separate dependency.
5. **Optional Fields**: If a type is wrapped in `{ "option": "type" }` in the IDL, translate it as an optional TypeScript property (`fieldName?: Type`).

## Type Conversion Matrix (2026 Stack)

| Anchor IDL Type | TypeScript Type | Import / Notes |
|---|---|---|
| `pubkey` | `Address` | `import { Address } from '@solana/web3.js'` |
| `u64`, `i64`, `u128`, `i128` | `bigint` | Native JS primitive |
| `u32`, `u16`, `u8`, `i32`, `i16`, `i8` | `number` | Native JS primitive |
| `bool` | `boolean` | Native JS primitive |
| `string` | `string` | Native JS primitive |
| `bytes` | `Uint8Array` | No import needed |
| `{ "option": T }` | `T \| null` | Optional field |
| `{ "vec": T }` | `T[]` | Array type |

## Reference Blueprint: Typed State Interface

When a user asks to convert an IDL account struct into a TypeScript interface, use this pattern:

```typescript
import { Address } from '@solana/web3.js';

// Generated from IDL accounts array — "UserProfile" account
export interface UserProfileState {
  authority: Address;          // IDL type: "pubkey"
  bump: number;                // IDL type: "u8"
  loyaltyPoints: bigint;       // IDL type: "u64"
  username: string;            // IDL type: "string"
  isActive: boolean;           // IDL type: "bool"
  metadataPointer?: Address;   // IDL type: { "option": "pubkey" }
  tags: string[];              // IDL type: { "vec": "string" }
}
```

## Reference Blueprint: IDL Error Map

Always extract the `errors` array from the IDL and generate this lookup structure for runtime error handling:

```typescript
// Generated from idl.errors array
export const PROGRAM_ERRORS: Record<number, string> = {
  6000: "InvalidUsernameLength: Username must be between 3 and 20 characters.",
  6001: "ProfileAlreadyInitialized: This wallet already has an active profile.",
  6002: "Unauthorized: Signer does not match the stored authority.",
};

export function parseProgramError(error: unknown): string {
  if (typeof error !== "object" || error === null) return "Unknown error occurred.";
  const logs: string[] = (error as any)?.logs ?? [];
  const match = logs.join("").match(/custom program error: (0x[0-9a-fA-F]+)/);
  if (match) {
    const code = parseInt(match[1], 16);
    return PROGRAM_ERRORS[code] ?? `Unrecognized program error code: ${code}`;
  }
  return (error as any)?.message ?? "An unknown onchain execution error occurred.";
}
```

## Reference Blueprint: Token-2022 Transfer Hook Extension Parser

When a user's mint uses the Token-2022 Transfer Hook extension, generate this typed decoder:

```typescript
import { Address, getBase58Decoder } from '@solana/web3.js';

export interface TransferHookExtension {
  programId: Address;
  authority: Address | null;
}

/**
 * Parses a Transfer Hook extension from raw Token-2022 mint account data.
 * Layout: [extensionType: u16][length: u16][programId: 32 bytes][authority option: 33 bytes]
 * Reference: https://spl.solana.com/token-2022/extensions
 *
 * Uses getBase58Decoder from @solana/web3.js (browser-safe, no Node.js Buffer required).
 */
export function parseTransferHookExtension(data: Uint8Array): TransferHookExtension | null {
  // Token-2022 base mint size is 82 bytes; extensions start after
  const MINT_BASE_SIZE = 82;
  const ACCOUNT_TYPE_SIZE = 1;
  const EXTENSION_HEADER_SIZE = 4; // 2 bytes type + 2 bytes length
  const PUBKEY_SIZE = 32;

  const base58Decoder = getBase58Decoder();
  let offset = MINT_BASE_SIZE + ACCOUNT_TYPE_SIZE;

  while (offset + EXTENSION_HEADER_SIZE <= data.length) {
    const extensionType = (data[offset] | (data[offset + 1] << 8));
    const extensionLength = (data[offset + 2] | (data[offset + 3] << 8));
    offset += EXTENSION_HEADER_SIZE;

    // TransferHook extension type = 25
    if (extensionType === 25 && offset + PUBKEY_SIZE <= data.length) {
      const programIdBytes = data.slice(offset, offset + PUBKEY_SIZE);
      // Browser-safe: use getBase58Decoder instead of Node.js Buffer
      const programId = base58Decoder.decode(programIdBytes) as Address;

      // Authority is an Option<Pubkey>: 1 byte discriminant + 32 bytes
      let authority: Address | null = null;
      if (offset + PUBKEY_SIZE + 1 <= data.length) {
        const hasAuthority = data[offset + PUBKEY_SIZE] === 1;
        if (hasAuthority && offset + PUBKEY_SIZE + 1 + PUBKEY_SIZE <= data.length) {
          const authBytes = data.slice(offset + PUBKEY_SIZE + 1, offset + PUBKEY_SIZE + 1 + PUBKEY_SIZE);
          // Browser-safe: use getBase58Decoder instead of Node.js Buffer
          authority = base58Decoder.decode(authBytes) as Address;
        }
      }

      return { programId, authority };
    }

    offset += extensionLength;
  }

  return null;
}
```
