// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {M1ZDestinationMinter} from "../../src/M1ZDestinationMinter.sol";
import {MissingOnez} from "../../src/MissingOnez.sol";


contract GrantRole is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address destinationMinterAddress = vm.envAddress("DESTINATION_MINTER_ADDRESS");
        address m1zAddress = vm.envAddress("M1Z_ADDRESS");

        
        vm.startBroadcast(deployerPrivateKey);
        
        MissingOnez m1z = MissingOnez(payable(m1zAddress));
        m1z.grantRole(m1z.CROSS_CHAIN_ROLE(), destinationMinterAddress);
        
        vm.stopBroadcast();
    }
}
