#!/bin/bash

source .env.local

# Check if required environment variables are set
if [ -z "$PRIVATE_KEY" ]; then
  echo "Error: PRIVATE_KEY environment variable is not set"
  exit 1
fi


# Run the Forge script to set allowed sources
forge script script/utils/SetAllowedSource.s.sol:SetAllowedSources \
  --rpc-url "$FUJI_TESTNET_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  --verify \
  -vvvv

echo "Allowed sources set successfully onnetwork"
