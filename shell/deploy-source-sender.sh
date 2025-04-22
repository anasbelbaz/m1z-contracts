#!/bin/bash

# Load environment variables
source .env.local

# Set up variables
NETWORK="core-testnet"
RPC_URL=$CORE_TESTNET_RPC_URL
CHAIN_ID=$CORE_TESTNET_CHAIN_ID
PRIVATE_KEY=$PRIVATE_KEY

# Check if M1Z_ADDRESS is set
if [ -z "$1" ]; then
  echo "Please provide the MissingOnez contract address"
  echo "Usage: sh shell/deploy-source-sender.sh <M1Z_ADDRESS>"
  exit 1
fi

M1Z_ADDRESS=$1
export M1Z_ADDRESS=$M1Z_ADDRESS

echo "Deploying to CORE Testnet ($CHAIN_ID) at $RPC_URL"
echo "Using MissingOnez contract at: $M1Z_ADDRESS"

# Deploy M1ZSourceSender contract
echo "Deploying M1ZSourceSender contract..."
forge script script/DeployM1ZSourceSender.s.sol:DeployM1ZSourceSender \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv

echo "M1ZSourceSender deployment completed!" 