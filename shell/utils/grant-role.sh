#!/bin/bash

source .env.local

# Check if required environment variables are set
if [ -z "$PRIVATE_KEY" ]; then
  echo "Error: PRIVATE_KEY environment variable is not set"
  exit 1
fi

if [ -z "$DESTINATION_MINTER_ADDRESS" ]; then
  echo "Error: DESTINATION_MINTER_ADDRESS environment variable is not set"
  exit 1
fi

if [ -z "$M1Z_ADDRESS" ]; then
  echo "Error: M1Z_ADDRESS environment variable is not set"
  exit 1
fi

echo "Granting role on $CORE_TESTNET_RPC_URL network..."
echo "Destination Minter Address: $DESTINATION_MINTER_ADDRESS"
echo "M1Z Address: $M1Z_ADDRESS"


# Run the Forge script to set allowed destinations
forge script script/utils/GrantRole.s.sol:GrantRole \
  --rpc-url "$CORE_TESTNET_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  -vvvv

echo "Role granted successfully on $CORE_TESTNET_RPC_URL network"
