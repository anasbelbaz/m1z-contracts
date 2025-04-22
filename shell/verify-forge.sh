#!/bin/bash

# Load environment variables
source .env.local

# Check if required parameters are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: sh shell/verify-forge.sh <CONTRACT_ADDRESS> <CONTRACT_NAME>"
  echo "Example: sh shell/verify-forge.sh 0xAba2C9ec10347e16207A51b006C715578A51aB2E MissingOnez"
  exit 1
fi

CONTRACT_ADDRESS=$1
CONTRACT_NAME=$2
API_KEY=$ETHERSCAN_API_KEY

# Check if API_KEY is set in .env.local
if [ -z "$API_KEY" ]; then
  echo "Error: ETHERSCAN_API_KEY is not set in your .env.local file"
  echo "Please add 'ETHERSCAN_API_KEY=your_api_key' to your .env.local file"
  exit 1
fi

echo "Verifying contract: $CONTRACT_NAME at $CONTRACT_ADDRESS"
echo "Using API Key from .env.local"

# Execute the verification command
forge verify-contract $CONTRACT_ADDRESS $CONTRACT_NAME \
  --verifier-url https://api.test2.btcs.network/api \
  --api-key $API_KEY \
  --watch

echo "Verification process completed." 