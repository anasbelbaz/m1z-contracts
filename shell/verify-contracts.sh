#!/bin/bash

# Load environment variables
source .env

# Contract addresses from deployment
M1Z_ADDRESS="0xAba2C9ec10347e16207A51b006C715578A51aB2E"
SOURCE_SENDER_ADDRESS="0xf48acceA05CF0f9Dce8C077f51fae5FcF32D2761"
DESTINATION_MINTER_ADDRESS="0x8476F4973778DCdEF7402Fa82145b69b083cC12d"

# Hardcode the deployer address - replace with your actual deployer address
DEPLOYER_ADDRESS="${DEPLOYER_ADDRESS:-0x4cf877ACA8eD18372BB28791c0c69339c27F7d78}"

# Check for API key
if [ -z "$COREDAO_API_KEY" ]; then
    echo "Warning: COREDAO_API_KEY is not set in .env file. Verification might fail."
    # Setting a default (likely invalid) API key to proceed
    COREDAO_API_KEY="YourApiKeyHere"
fi

# Build contracts first
echo "Building contracts..."
cd "$(dirname "$0")/.."  # Navigate to the project root
forge build --force
echo "Build completed."

# First create the constructor args hex strings
echo "Preparing constructor arguments..."

MISSING_ONEZ_ARGS=$(cast abi-encode "constructor(address,address,uint256,uint256,uint256,string)" "$DEPLOYER_ADDRESS" "$DEPLOYER_ADDRESS" "100000000000000000" "1" "1001" "unrevealed.json")
echo "MissingOnez args: $MISSING_ONEZ_ARGS"

SOURCE_SENDER_ARGS=$(cast abi-encode "constructor(address,address,address,uint256,address)" "$DEPLOYER_ADDRESS" "0xF7Cc8b0B5263A74AFBb1a2ac87FfF1CF7E62152f" "0x3902228D6A3d2Dc44731fD9d45FeE6a61c722D0b" "100000000000000000" "$M1Z_ADDRESS")
echo "M1ZSourceSender args: $SOURCE_SENDER_ARGS"

DESTINATION_MINTER_ARGS=$(cast abi-encode "constructor(address,address,address)" "$DEPLOYER_ADDRESS" "0xF7Cc8b0B5263A74AFBb1a2ac87FfF1CF7E62152f" "$M1Z_ADDRESS")
echo "M1ZDestinationMinter args: $DESTINATION_MINTER_ARGS"

# Contracts verification for Core mainnet
echo "Verifying MissingOnez contract at address $M1Z_ADDRESS..."
forge verify-contract \
    --chain-id 1116 \
    --compiler-version v0.8.20+commit.a1b79de6 \
    --constructor-args "$MISSING_ONEZ_ARGS" \
    --etherscan-api-key "$COREDAO_API_KEY" \
    "$M1Z_ADDRESS" \
    "MissingOnez"

echo "Verifying M1ZSourceSender contract at address $SOURCE_SENDER_ADDRESS..."
forge verify-contract \
    --chain-id 1116 \
    --compiler-version v0.8.20+commit.a1b79de6 \
    --constructor-args "$SOURCE_SENDER_ARGS" \
    --etherscan-api-key "$COREDAO_API_KEY" \
    "$SOURCE_SENDER_ADDRESS" \
    "M1ZSourceSender"

echo "Verifying M1ZDestinationMinter contract at address $DESTINATION_MINTER_ADDRESS..."
forge verify-contract \
    --chain-id 1116 \
    --compiler-version v0.8.20+commit.a1b79de6 \
    --constructor-args "$DESTINATION_MINTER_ARGS" \
    --etherscan-api-key "$COREDAO_API_KEY" \
    "$DESTINATION_MINTER_ADDRESS" \
    "M1ZDestinationMinter"

echo "Verification process completed!" 