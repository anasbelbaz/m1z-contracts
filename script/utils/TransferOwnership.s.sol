// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MissingOnez} from "../../src/MissingOnez.sol";

/**
 * @title TransferOwnership
 * @notice Script to transfer ownership of the M1Z NFT contract to the DestinationMinter contract
 */
contract TransferOwnership is Script {
    function run() external {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address m1zAddress = vm.envAddress("M1Z_ADDRESS");
        address destinationMinterAddress = vm.envAddress("DESTINATION_MINTER_ADDRESS");

        // Log the addresses
        console.log("M1Z NFT Address:", m1zAddress);
        console.log("Destination Minter Address:", destinationMinterAddress);

        // Start the broadcast to send transactions
        vm.startBroadcast(deployerPrivateKey);

        // Get the M1Z contract instance
        MissingOnez m1z = MissingOnez(m1zAddress);
        
        // Get current owner for logging
        address currentOwner = m1z.owner();
        console.log("Current owner:", currentOwner);
        
        // Transfer ownership to the destination minter
        m1z.transferOwnership(destinationMinterAddress);
        console.log("Ownership transferred to:", destinationMinterAddress);
        
        // Verify the new owner
        address newOwner = m1z.owner();
        console.log("New owner verified:", newOwner);

        // End the broadcast
        vm.stopBroadcast();
    }
}
