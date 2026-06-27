# Token-2022 Transfer Hook Example

This example documents the expected output shape for a Token-2022 mint that uses a transfer hook and optional extra account metas.

## Required Output

Generated bridge code should include:

- A mint fetcher using `createSolanaRpc()`.
- Browser-safe base64 decoding.
- A transfer hook extension parser.
- A typed result for the hook program id and authority.
- A clear note when extra account meta addresses are required but not present in the IDL or user input.

## Expected Types

```typescript
import type { Address } from '@solana/web3.js';

export interface TransferHookExtension {
  programId: Address;
  authority: Address | null;
}

export interface Token2022MintBridge {
  rawData: Uint8Array;
  transferHook: TransferHookExtension | null;
  missingExtraAccountMetas: boolean;
}
```

## Expected Fetch Shape

```typescript
import { address, createSolanaRpc } from '@solana/web3.js';
import { parseTransferHookExtension } from './token2022';

export async function fetchToken2022MintBridge(
  rpcUrl: string,
  mintAddress: string
): Promise<Token2022MintBridge> {
  const rpc = createSolanaRpc(rpcUrl);
  const accountInfo = await rpc
    .getAccountInfo(address(mintAddress), { encoding: 'base64' })
    .send();

  if (!accountInfo.value) {
    throw new Error(`Mint account not found: ${mintAddress}`);
  }

  const rawData = Uint8Array.from(
    atob(accountInfo.value.data as unknown as string),
    (char) => char.charCodeAt(0)
  );

  const transferHook = parseTransferHookExtension(rawData);

  return {
    rawData,
    transferHook,
    missingExtraAccountMetas: transferHook !== null,
  };
}
```

The bridge must not invent extra account metas. If the transfer hook program requires them, ask the user for the hook program's extra account meta list or source IDL.
