// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {MissingOnez} from "../src/MissingOnez.sol";
import {M1ZSourceSender} from "../src/M1ZSourceSender.sol";
import {M1ZDestinationMinter} from "../src/M1ZDestinationMinter.sol";

contract DeployAll is Script {
    function setUp() public {}

    // Configuration parameters for deployment - hardcoded for tracking
    address public routerAddress = 0xF7Cc8b0B5263A74AFBb1a2ac87FfF1CF7E62152f; // Chainlink CCIP Router
    address public linkAddress = 0x3902228D6A3d2Dc44731fD9d45FeE6a61c722D0b; // LINK token
    uint256 public unitPrice = 100000000000000000; // 0.1 ETH
    uint256 public minId = 1;
    uint256 public maxId = 1001;
    string public unrevealedPath = "unrevealed.json";

    // Chain selectors for cross-chain configuration
    uint64[] public sourceChainSelectors;    
    uint64[] public destinationChainSelectors;

    function run() public {
        // Only get PRIVATE_KEY from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address royaltyRecipient = deployer;
        
        // Hardcoded chain selectors
        sourceChainSelectors = new uint64[](2);
        sourceChainSelectors[0] = 5009297550715157269; // Sepolia
        sourceChainSelectors[1] = 6433500567565415381; // Avalanche Fuji

        destinationChainSelectors = new uint64[](2);
        destinationChainSelectors[0] = 5009297550715157269; // Sepolia
        destinationChainSelectors[1] = 6433500567565415381; // Avalanche Fuji

        console2.log("Starting deployment with parameters:");
        console2.log("Deployer:", deployer);
        console2.log("Router Address:", routerAddress);
        console2.log("LINK Address:", linkAddress);
        console2.log("Unit Price:", unitPrice);
        console2.log("Min ID:", minId);
        console2.log("Max ID:", maxId);
        console2.log("Unrevealed Path:", unrevealedPath);
        console2.log("Source Chain Selectors: Sepolia, Avalanche Fuji");
        console2.log("Destination Chain Selectors: Sepolia, Avalanche Fuji");

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy MissingOnez NFT contract
        console2.log("Deploying MissingOnez...");
        MissingOnez m1z = new MissingOnez(
            deployer,
            royaltyRecipient,
            unitPrice,
            minId,
            maxId,
            unrevealedPath
        );
        console2.log("MissingOnez deployed at:", address(m1z));

        // Step 2: Deploy M1ZSourceSender contract
        console2.log("Deploying M1ZSourceSender...");
        M1ZSourceSender sourceSender = new M1ZSourceSender(
            deployer,
            routerAddress,
            linkAddress,
            unitPrice,
            address(m1z)
        );
        console2.log("M1ZSourceSender deployed at:", address(sourceSender));

        // Step 3: Deploy M1ZDestinationMinter contract
        console2.log("Deploying M1ZDestinationMinter...");
        M1ZDestinationMinter destinationMinter = new M1ZDestinationMinter(
            deployer,
            routerAddress,
            address(m1z)
        );
        console2.log("M1ZDestinationMinter deployed at:", address(destinationMinter));

        // Step 4: Configure allowed destinations for the source sender
        console2.log("Setting allowed destinations for M1ZSourceSender...");
        sourceSender.setAllowedDestinations(destinationChainSelectors, true);
        console2.log("Allowed destinations set successfully");

        // Step 5: Configure allowed sources for the destination minter
        console2.log("Setting allowed sources for M1ZDestinationMinter...");
        destinationMinter.setAllowedSources(sourceChainSelectors, true);
        console2.log("Allowed sources set successfully");

        // Step 6: Grant CROSS_CHAIN_ROLE to the destination minter
        console2.log("Granting CROSS_CHAIN_ROLE to M1ZDestinationMinter...");
        m1z.grantRole(m1z.CROSS_CHAIN_ROLE(), address(destinationMinter));
        console2.log("CROSS_CHAIN_ROLE granted successfully");

        // Enable cross-chain minting
        console2.log("Enabling cross-chain minting...");
        sourceSender.setCanMintCrossChain(true);
        console2.log("Cross-chain minting enabled");
        
        vm.stopBroadcast();

        // Log summary of deployed contracts
        console2.log("\nDeployment Summary:");
        console2.log("MissingOnez: ", address(m1z));
        console2.log("M1ZSourceSender: ", address(sourceSender));
        console2.log("M1ZDestinationMinter: ", address(destinationMinter));
        console2.log("\nConfiguration complete, all contracts are ready for use!");
    }
} 