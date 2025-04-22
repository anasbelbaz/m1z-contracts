# Manual Contract Verification Guide for Core Testnet

## M1ZDestinationMinter Contract

### Contract Details

- Contract Address: `0x8476F4973778DCdEF7402Fa82145b69b083cC12d`
- Contract Name: `M1ZDestinationMinter`
- Compiler Version: `v0.8.20+commit.a1b79de6`
- Optimization: `Yes`
- Optimization Runs: `200`
- EVM Version: `london`

### Constructor Arguments (ABI-encoded)

```
0x0000000000000000000000004cf877aca8ed18372bb28791c0c69339c27f7d78000000000000000000000000ded0ee188fe8f1706d9049e29c82081a5ebecb2f000000000000000000000000aba2c9ec10347e16207a51b006c715578a51ab2e
```

### Source Code

The flattened source code is available at: `flattened/M1ZDestinationMinter.sol`

### Verification Steps

1. Go to the Core Testnet block explorer: https://scan.test2.btcs.network
2. Navigate to your contract address page: https://scan.test2.btcs.network/address/0x8476F4973778DCdEF7402Fa82145b69b083cC12d
3. Click on the "Code" tab
4. Click "Verify & Publish"
5. Fill in the form with the details provided above:
   - Contract Address: already filled
   - Compiler: select `v0.8.20+commit.a1b79de6`
   - Optimization: select `Yes`
   - EVM Version: select `london` (from the Misc Settings dropdown)
6. Paste the flattened contract source code from `flattened/M1ZDestinationMinter.sol`
7. Paste the ABI-encoded constructor arguments
8. Click "Verify and Publish"

### Tips for Successful Verification

- Make sure the compiler version exactly matches the one used for deployment
- The constructor arguments must be exact
- If verification fails, double-check the contract source code for any discrepancies
- Some Blockscout instances require the file to have the exact same pragma directive as when it was deployed

### Common Issues

- If you get a "bytecode mismatch" error, ensure that:
  1. The optimization setting matches what was used during deployment
  2. The EVM version is correct
  3. The compiler version is exactly the same
  4. All source code files are included in the flattened version

### After Verification

Once verified, you'll be able to:

- Read the contract's source code on the block explorer
- Interact with the contract through the block explorer's UI
- See the contract's events and full transaction details
