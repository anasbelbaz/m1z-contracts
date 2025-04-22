#!/bin/bash

# Load environment variables
source .env.local

# Set up variables
RPC_URL=$CORE_TESTNET_RPC_URL
CHAIN_ID=$CORE_TESTNET_CHAIN_ID
PRIVATE_KEY=$PRIVATE_KEY



echo "Deploying to CORE Testnet ($CHAIN_ID) at $RPC_URL"

# Deploy M1ZDestinationMinter contract
echo "Deploying M1ZDestinationMinter contract..."
forge script script/DeployM1ZDestinationMinter.s.sol:DeployM1ZDestinationMinter \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv

echo "M1ZDestinationMinter deployment completed!" 