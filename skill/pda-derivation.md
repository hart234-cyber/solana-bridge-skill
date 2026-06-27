# Submodule: PDA Derivation and Account Resolution

This document defines how to derive and validate Program Derived Addresses from Anchor IDLs and frontend inputs.

## Core Rules

1. **Use IDL Seeds First**: If the Anchor IDL includes `pda.seeds`, derive addresses from those seeds. Do not infer PDA seeds from account names alone.
2. **Preserve Seed Order**: PDA seed order is part of the address. Generate code in the exact order shown in the IDL.
3. **Separate v2 and Anchor Boundaries**: Use Web3.js v2 address values for direct RPC code. Convert to the aliased v1 `PublicKey` only when passing accounts into Anchor `.accounts()` or `program.account.*.fetch`.
4. **Reject Missing Dynamic Seeds**: If an IDL seed references an account, argument, or field not provided by the user, ask for the missing input instead of generating a placeholder.
5. **Return Bump Values**: PDA helpers should return both `address` and `bump` when the derivation API exposes the bump.
6. **Use Browser-Safe Seed Encoding**: Use `TextEncoder` for string constants in browser code. Avoid Node-only `Buffer`.

## Seed Mapping

| IDL seed kind | Frontend input | Encoding rule |
|---|---|---|
| `const` bytes | IDL-provided byte array | `new Uint8Array([...])` |
| string constant | IDL-provided UTF-8 string | `new TextEncoder().encode(value)` |
| account pubkey | user/account address | public key bytes |
| instruction arg | hook/function argument | encode according to IDL type |

## Reference Blueprint: PDA Helper from IDL Seeds

When the IDL includes a profile PDA with seeds `["profile", authority]`, generate a helper like this:

```typescript
import {
  Address,
  address,
  getAddressEncoder,
  getProgramDerivedAddress,
} from '@solana/web3.js';

export interface UserProfilePda {
  address: Address;
  bump: number;
}

export async function deriveUserProfilePda(
  programAddress: string,
  authorityAddress: string
): Promise<UserProfilePda> {
  const programId = address(programAddress);
  const authority = address(authorityAddress);
  const addressEncoder = getAddressEncoder();

  const [profileAddress, bump] = await getProgramDerivedAddress({
    programAddress: programId,
    seeds: [
      new TextEncoder().encode('profile'),
      addressEncoder.encode(authority),
    ],
  });

  return {
    address: profileAddress,
    bump,
  };
}
```

## Reference Blueprint: Anchor Account Conversion

When an Anchor transaction hook needs the derived PDA, keep conversion local to the Anchor boundary:

```typescript
import { PublicKey } from '@solana/web3.js-v1';
import { deriveUserProfilePda } from './pda';

export async function deriveUserProfilePublicKey(
  programAddress: string,
  authorityAddress: string
): Promise<PublicKey> {
  const { address: profileAddress } = await deriveUserProfilePda(
    programAddress,
    authorityAddress
  );

  return new PublicKey(profileAddress);
}
```

## Reference Blueprint: Dynamic Seed Guard

If a PDA seed depends on an instruction argument, make the argument explicit:

```typescript
export interface DeriveVaultPdaArgs {
  programAddress: string;
  authorityAddress: string;
  vaultName: string;
}
```

Do not generate a fake `vaultName`, `authority`, or `programAddress`. If the user did not provide the dynamic seed value, stop and ask for it.
