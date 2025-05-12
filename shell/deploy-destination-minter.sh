#!/bin/bash

# Load environment variables
source .env.local




echo "Deploying to $RPC_URL"

# Deploy M1ZDestinationMinter contract
echo "Deploying M1ZDestinationMinter contract..."
forge script script/DeployM1ZDestinationMinter.s.sol:DeployM1ZDestinationMinter \
  --rpc-url $FUJI_TESTNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv

echo "M1ZDestinationMinter deployment completed!" 