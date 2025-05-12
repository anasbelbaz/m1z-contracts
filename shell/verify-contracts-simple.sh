#!/bin/bash

# Load environment variables
source .env

# Contract addresses from deployment
M1Z_ADDRESS="0xAba2C9ec10347e16207A51b006C715578A51aB2E"
SOURCE_SENDER_ADDRESS="0xf48acceA05CF0f9Dce8C077f51fae5FcF32D2761"
DESTINATION_MINTER_ADDRESS="0x8476F4973778DCdEF7402Fa82145b69b083cC12d"

# First create the constructor args hex strings
MISSING_ONEZ_ARGS=$(cast abi-encode "constructor(address,address,uint256,uint256,uint256,string)" "$DEPLOYER_ADDRESS" "$DEPLOYER_ADDRESS" "100000000000000000" "1" "1001" "unrevealed.json")

SOURCE_SENDER_ARGS=$(cast abi-encode "constructor(address,address,address,uint256,address)" "$DEPLOYER_ADDRESS" "0xF7Cc8b0B5263A74AFBb1a2ac87FfF1CF7E62152f" "0x3902228D6A3d2Dc44731fD9d45FeE6a61c722D0b" "100000000000000000" "$M1Z_ADDRESS")

DESTINATION_MINTER_ARGS=$(cast abi-encode "constructor(address,address,address)" "$DEPLOYER_ADDRESS" "0xF7Cc8b0B5263A74AFBb1a2ac87FfF1CF7E62152f" "$M1Z_ADDRESS")

# Verify MissingOnez contract
echo "Verifying MissingOnez contract at address $M1Z_ADDRESS..."
forge verify-contract --chain core-mainnet \
    --watch \
    "$M1Z_ADDRESS" \
    "src/MissingOnez.sol:MissingOnez" \
    --constructor-args "$MISSING_ONEZ_ARGS"

# Verify M1ZSourceSender contract
echo "Verifying M1ZSourceSender contract at address $SOURCE_SENDER_ADDRESS..."
forge verify-contract --chain core-mainnet \
    --watch \
    "$SOURCE_SENDER_ADDRESS" \
    "src/M1ZSourceSender.sol:M1ZSourceSender" \
    --constructor-args "$SOURCE_SENDER_ARGS"

# Verify M1ZDestinationMinter contract
echo "Verifying M1ZDestinationMinter contract at address $DESTINATION_MINTER_ADDRESS..."
forge verify-contract --chain core-mainnet \
    --watch \
    "$DESTINATION_MINTER_ADDRESS" \
    "src/M1ZDestinationMinter.sol:M1ZDestinationMinter" \
    --constructor-args "$DESTINATION_MINTER_ARGS"

echo "Verification process completed!" 