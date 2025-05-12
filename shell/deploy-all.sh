#!/bin/bash




source .env



# Display deployment information
echo "Deploying contracts to $CORE_MAINNET_RPC_URL network"
echo "Using hardcoded parameters in the Solidity script"

# Execute the deployment script
forge script script/DeployAll.s.sol:DeployAll \
    --rpc-url $CORE_MAINNET_RPC_URL  \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    -vvvv

echo "Deployment completed!" 