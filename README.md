# solidity-version-proxy

Yet another smart contract upgrade pattern.

Versioned proxies allow users either to opt-in for upgrades or delegate responsability to a third party simultaneous upgrades.

This implementation aims for minimal deployment gas cost.

## What this is good for

- Contracts controlled by user.
- Contracts with limited storage usage.
- Contracts with multiple identical copies.

Notable example: Smart contract wallets

## What this is NOT good for

- Contracts with strong immutability requirements.
- Contracts used by multiple parties.
- Contracts that use self-destruct.

Notable example: ERC20 Tokens
