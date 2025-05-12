// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {M1ZDestinationMinter} from "../../src/M1ZDestinationMinter.sol";

contract SetAllowedSources is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address destinationMinterAddress = vm.envAddress("FUJI_DESTINATION_MINTER_ADDRESS");
        
        // Get chain selectors from environment variables or hardcode them
        // These are the chain selectors for the source chains that are allowed to send messages
        uint64[] memory allowedSources = new uint64[](2);
        allowedSources[0] = 16015286601757825753; // sepolia
        allowedSources[1] = 4264732132125536123; // core testnet

        vm.startBroadcast(deployerPrivateKey);
        
        M1ZDestinationMinter destinationMinter = M1ZDestinationMinter(payable(destinationMinterAddress));
        destinationMinter.setAllowedSources(allowedSources, true);
        
        vm.stopBroadcast();
    }
}
