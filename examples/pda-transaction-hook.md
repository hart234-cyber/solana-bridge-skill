# PDA Transaction Hook Example

This example shows the expected pattern when a React transaction hook needs a PDA derived from Anchor IDL seeds.

## Source IDL Detail

```json
{
  "name": "userProfile",
  "pda": {
    "seeds": [
      { "kind": "const", "value": [112, 114, 111, 102, 105, 108, 101] },
      { "kind": "account", "path": "authority" }
    ]
  }
}
```

## Expected Helper Shape

```typescript
import {
  address,
  getAddressEncoder,
  getProgramDerivedAddress,
  type Address,
} from '@solana/web3.js';

export async function deriveUserProfilePda(
  programAddress: string,
  authorityAddress: string
): Promise<{ address: Address; bump: number }> {
  const [profileAddress, bump] = await getProgramDerivedAddress({
    programAddress: address(programAddress),
    seeds: [
      new TextEncoder().encode('profile'),
      getAddressEncoder().encode(address(authorityAddress)),
    ],
  });

  return { address: profileAddress, bump };
}
```

## Expected Hook Boundary

```typescript
import { PublicKey, SystemProgram } from '@solana/web3.js-v1';
import { deriveUserProfilePda } from './pda';

const { address: profileAddress } = await deriveUserProfilePda(
  programId,
  authorityAddress
);

await program.methods
  .updateProfile(username)
  .accounts({
    userProfile: new PublicKey(profileAddress),
    authority: new PublicKey(authorityAddress),
    systemProgram: SystemProgram.programId,
  })
  .rpc();
```

The v1 `PublicKey` conversion stays at the Anchor boundary. Direct RPC helpers keep using Web3.js v2 types.
