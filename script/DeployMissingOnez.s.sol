// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "../src/MissingOnez.sol";

contract DeployMissingOnez is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address royaltyRecipient = deployer;
        uint256 unitPrice = 100000000000000000;
        uint256 minId = 1;
        uint256 maxId = 1001;
        string memory unrevealedPath = "unrevealed.json";

        console2.log("Deploying MissingOnez with parameters:");
        console2.log("Deployer:", deployer);
        console2.log("Royalty Recipient:", royaltyRecipient);
        console2.log("Unit Price:", unitPrice);
        console2.log("Min ID:", minId);
        console2.log("Max ID:", maxId);
        console2.log("Unrevealed Path:", unrevealedPath);

        vm.startBroadcast(deployerPrivateKey);

        MissingOnez m1z = new MissingOnez(deployer, royaltyRecipient, unitPrice, minId, maxId, unrevealedPath);

        console2.log("MissingOnez deployed at:", address(m1z));

        vm.stopBroadcast();
    }
}
