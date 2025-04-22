# MissingOnez NFT Contracts

This repository contains the smart contracts for the MissingOnez NFT collection, built with Foundry.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (Forge, Cast, Anvil)
- Solidity ^0.8.20

## Key Contracts

- **MissingOnez.sol**: Main NFT contract implementing ERC721 with enumerable and burnable extensions.
- **RandomPoolId.sol**: Utility contract for random ID assignment.
- **M1ZPrices.sol**: Handles pricing logic for minting tokens.
- **Withdraw.sol**: Handles ETH and token withdrawal functionality.
- **StringUtils.sol**: Utility functions for string manipulation.

## Getting Started

1. Clone the repository:

```shell
git clone <repository-url>
cd smartcontracts
```

2. Install dependencies:

```shell
forge install
```

3. Build the contracts:

```shell
forge build
```

4. Run tests:

```shell
forge test
```

## Environment Setup

Copy the example environment file and fill in your values:

```shell
cp .env.example .env
```

Edit the `.env` file with your deployment configuration:

- Private key for deployment
- Royalty recipient address
- Unit price for minting
- Min and max IDs for the token range
- Unrevealed metadata path
- RPC URLs for target networks

## Deployment

To deploy to a network:

```shell
# Load environment variables
source .env

# Deploy to a specific network
forge script script/DeployMissingOnez.s.sol:DeployMissingOnez --rpc-url $AVALANCHE_RPC_URL --broadcast --verify
```

## Contract Features

### Minting

- Free minting via CROSS_CHAIN_ROLE (for cross-chain transfers or giveaways)
- Paid minting with quantity-based discounts
- Batch minting (up to MAX_BATCH_MINT = 10)

### Token Reveal

- Manual reveal by token owners
- Auto-reveal functionality for admins
- Separate metadata paths for revealed and unrevealed tokens

### Cross-Chain

- Support for cross-chain transfers via CCIP
- Burn and mint mechanism for cross-chain operations

## License

This project is licensed under the MIT License.
