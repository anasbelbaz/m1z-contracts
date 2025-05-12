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

## Unified Deployment

### DeployAll

A unified deployment script has been created to simplify the deployment process of all contracts at once. This script:

1. Deploys the MissingOnez NFT contract
2. Deploys the M1ZSourceSender contract
3. Deploys the M1ZDestinationMinter contract
4. Configures allowed destinations for the source sender
5. Configures allowed sources for the destination minter
6. Grants CROSS_CHAIN_ROLE to the destination minter
7. Enables cross-chain minting

All parameters are hardcoded in the script for easy tracking and modification.

### How to use

Run the shell script:

```bash
chmod +x shell/deploy-all.sh
./shell/deploy-all.sh <network>
```

Where `<network>` is the RPC URL name configured in your Foundry setup (default: sepolia).

### Required Environment Variables

The deployment only requires the following:

- `PRIVATE_KEY` (required): Your private key for signing transactions

Example:

```bash
export PRIVATE_KEY=your_private_key
./shell/deploy-all.sh avalanche-fuji
```

### Hardcoded Parameters

The following parameters are hardcoded in the script for easier tracking:

- Router Address: `0xF694E193200268f9a4868e4Aa017A0118C9a8177`
- Link Address: `0x6C475841d1D7871940E93579E5DBaE01634e17aA`
- Unit Price: 0.1 ETH
- Min ID: 1
- Max ID: 1001
- Chain Selectors: Sepolia and Avalanche Fuji

To modify these parameters, edit the values directly in `script/DeployAll.s.sol`.

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
