#!/bin/bash

source .env.local

# Check if required environment variables are set
if [ -z "$PRIVATE_KEY" ]; then
  echo "Error: PRIVATE_KEY environment variable is not set"
  exit 1
fi

echo "Setting allowed destinations on $CORE_TESTNET_RPC_URL network..."

# Run the Forge script to set allowed destinations
forge script script/utils/TransferOwnership.s.sol:TransferOwnership \
  --rpc-url "$CORE_TESTNET_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \

echo "Allowed destinations set successfully on $CORE_TESTNET_RPC_URL network"
