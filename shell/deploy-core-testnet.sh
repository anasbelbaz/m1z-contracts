#!/bin/bash

# Load environment variables
source .env.local

# Set up variables
NETWORK="core-testnet"
RPC_URL=$CORE_TESTNET_RPC_URL
CHAIN_ID=$CORE_TESTNET_CHAIN_ID
PRIVATE_KEY=$PRIVATE_KEY

echo "Deploying to CORE Testnet ($CHAIN_ID) at $RPC_URL"

# Deploy MissingOnez contract
echo "Deploying MissingOnez contract..."
forge script script/DeployMissingOnez.s.sol:DeployMissingOnez --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify

# Deploy M1ZSourceSender contract
echo "Deploying M1ZSourceSender contract..."
forge script script/DeployM1ZSourceSender.s.sol:DeployM1ZSourceSender --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify

# Deploy M1ZDestinationMinter contract
echo "Deploying M1ZDestinationMinter contract..."
forge script script/DeployM1ZDestinationMinter.s.sol:DeployM1ZDestinationMinter --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify

echo "Deployment completed!" 