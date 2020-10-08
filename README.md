# solidity-version-proxy

Yet another smart contract upgrade pattern.

## What this is good for

Contracts where the implementation is controlled by a user, but the user can opt-in to let a third party submit upgrades.

Notable example: Smart contract wallets

## What this is NOT good for

Contracts with strong immutability requirements. Contracts used by multiple parties.

Notable example: ERC20 Tokens
