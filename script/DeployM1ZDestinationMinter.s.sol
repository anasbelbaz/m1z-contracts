// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "../src/M1ZDestinationMinter.sol";

contract DeployM1ZDestinationMinter is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // Get configuration from environment variables or use defaults
        address routerAddress = 0xded0EE188Fe8F1706D9049e29C82081A5ebEcb2F; // Default CORE testnet router
        address m1zAddress = 0xAba2C9ec10347e16207A51b006C715578A51aB2E;

        console2.log("Deploying M1ZDestinationMinter with parameters:");
        console2.log("Deployer:", deployer);
        console2.log("Router Address:", routerAddress);
        console2.log("M1Z Address:", m1zAddress);

        vm.startBroadcast(deployerPrivateKey);

        M1ZDestinationMinter destinationMinter = new M1ZDestinationMinter(deployer, routerAddress, m1zAddress);

        console2.log("M1ZDestinationMinter deployed at:", address(destinationMinter));

        vm.stopBroadcast();
    }
}
