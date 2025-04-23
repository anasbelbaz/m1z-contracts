// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "../src/M1ZSourceSender.sol";

contract DeployM1ZSourceSender is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // Get configuration from environment variables or use defaults
        address routerAddress = 0xded0EE188Fe8F1706D9049e29C82081A5ebEcb2F; // Default CORE testnet router
        address linkAddress = 0x6C475841d1D7871940E93579E5DBaE01634e17aA; // Default CORE testnet LINK
        uint256 unitPrice = 100000000000000000; // 0.1 ETH default
        address m1zAddress = 0xAba2C9ec10347e16207A51b006C715578A51aB2E;

        console2.log("Deploying M1ZSourceSender with parameters:");
        console2.log("Deployer:", deployer);
        console2.log("Router Address:", routerAddress);
        console2.log("LINK Address:", linkAddress);
        console2.log("Unit Price:", unitPrice);
        console2.log("M1Z Address:", m1zAddress);

        vm.startBroadcast(deployerPrivateKey);

        M1ZSourceSender sourceSender = new M1ZSourceSender(deployer, routerAddress, linkAddress, unitPrice, m1zAddress);

        console2.log("M1ZSourceSender deployed at:", address(sourceSender));

        vm.stopBroadcast();
    }
}
