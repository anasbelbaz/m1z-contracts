// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {M1ZSourceSender} from "../../src/M1ZSourceSender.sol";

contract SetAllowedDestinations is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address sourceSenderAddress = vm.envAddress("SOURCE_SENDER_ADDRESS");
        
        // Chain selectors for the destination chains that are allowed to receive messages
        uint64[] memory allowedDestinations = new uint64[](2);
        allowedDestinations[0] = 16015286601757825753; // Sepolia
        allowedDestinations[1] = 14767482510784806043; // Avalanche Fuji
        
        vm.startBroadcast(deployerPrivateKey);
        
        M1ZSourceSender sourceSender = M1ZSourceSender(payable(sourceSenderAddress));
        sourceSender.setAllowedDestinations(allowedDestinations, true);
        
        vm.stopBroadcast();
    }
}
