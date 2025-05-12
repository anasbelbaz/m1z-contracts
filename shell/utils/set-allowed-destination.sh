#!/bin/bash

source .env.local

# Check if required environment variables are set
if [ -z "$PRIVATE_KEY" ]; then
  echo "Error: PRIVATE_KEY environment variable is not set"
  exit 1
fi

if [ -z "$SOURCE_SENDER_ADDRESS" ]; then
  echo "Error: SOURCE_SENDER_ADDRESS environment variable is not set"
  exit 1
fi


echo "Setting allowed destinations on $CORE_TESTNET_RPC_URL network..."
echo "Source Sender Address: $SOURCE_SENDER_ADDRESS"

# Navigate to the project root directory
cd "$(dirname "$0")/../.." || exit

# Run the Forge script to set allowed destinations
forge script script/utils/SetAllowedDestination.s.sol:SetAllowedDestinations \
  --rpc-url "$CORE_TESTNET_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  --verify \
  -vvvv

echo "Allowed destinations set successfully on $CORE_TESTNET_RPC_URL network"
