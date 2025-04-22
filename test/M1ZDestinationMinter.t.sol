// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MissingOnez.sol";

// Mock Client library for CCIP
library CCIPClient {
    struct Any2EVMMessage {
        bytes32 messageId;
        uint64 sourceChainSelector;
        bytes sender;
        bytes data;
        bytes[] tokenAmounts;
    }
}

// Mock M1ZDestinationMinter with simplified implementation
contract MockM1ZDestinationMinter {
    address public owner;
    address public router;
    address public m1zAddress;
    
    // Track supported chains
    mapping(uint64 => bool) public supportedChainSelectors;
    // Track authorized senders
    mapping(bytes => bool) public authorizedSenders;
    
    event CCIPReceived(bytes32 messageId, uint64 sourceChainSelector, address sender);
    
    constructor(address _owner, address _router, address _m1zAddress) {
        owner = _owner;
        router = _router;
        m1zAddress = _m1zAddress;
    }
    
    function setSupportedChainSelectors(uint64[] calldata _chainSelectors, bool supported) external {
        require(msg.sender == owner, "Not authorized");
        for (uint i = 0; i < _chainSelectors.length; i++) {
            supportedChainSelectors[_chainSelectors[i]] = supported;
        }
    }
    
    function setAuthorizedSenders(bytes[] calldata _senders, bool authorized) external {
        require(msg.sender == owner, "Not authorized");
        for (uint i = 0; i < _senders.length; i++) {
            authorizedSenders[_senders[i]] = authorized;
        }
    }
    
    function setM1ZAddress(address _m1zAddress) external {
        require(msg.sender == owner, "Not authorized");
        m1zAddress = _m1zAddress;
    }
    
    // Simulate CCIP receiving a message
    function ccipReceive(CCIPClient.Any2EVMMessage calldata message) external returns (bool) {
        // Check if the source chain is supported
        require(supportedChainSelectors[message.sourceChainSelector], "Source chain not supported");
        
        // Check if sender is authorized
        require(authorizedSenders[message.sender], "Sender not authorized");
        
        // Process the message based on function selector
        bytes4 functionSelector = bytes4(message.data[:4]);
        
        // Handle different function calls
        if (functionSelector == bytes4(keccak256("mint(uint256,address)"))) {
            // Handle mint function
            (uint256 amount, address to) = abi.decode(message.data[4:], (uint256, address));
            
            // Call the M1Z contract (this is a mock)
            // In a real implementation, this would call the actual mint function on the M1Z contract
            MissingOnez(m1zAddress).mint(amount, to);
        } else if (functionSelector == bytes4(keccak256("mintFromCrossChainTransfer(uint256[],uint256[],address,uint256)"))) {
            // Handle cross-chain transfer
            (uint256[] memory tokenIds, uint256[] memory ids, address to, uint256 fromChainId) = 
                abi.decode(message.data[4:], (uint256[], uint256[], address, uint256));
            
            // Call the M1Z contract (this is a mock)
            MissingOnez(m1zAddress).mintFromCrossChainTransfer(tokenIds, ids, to, fromChainId);
        }
        
        emit CCIPReceived(message.messageId, message.sourceChainSelector, address(0));
        return true;
    }
}

contract M1ZDestinationMinterTest is Test {
    MockM1ZDestinationMinter public destinationMinter;
    MissingOnez public m1z;
    
    address public owner;
    address public user;
    uint64 public sourceChainSelector = 1;
    bytes public senderAddress;
    
    bytes32 public constant CROSS_CHAIN_ROLE = keccak256("CROSS_CHAIN_ROLE");
    
    // Simulate CCIP message events
    event CCIPReceived(bytes32 messageId, uint64 sourceChainSelector, address sender);
    
    function setUp() public {
        owner = address(this);
        user = address(0x456);
        senderAddress = abi.encode(address(0x789));
        
        // Deploy MissingOnez
        m1z = new MissingOnez(
            owner,
            address(0x123),  // royalty recipient
            0.1 ether,       // unit price
            1,               // min ID
            1001,            // max ID (1000 tokens total)
            "unrevealed.json"
        );
        
        // Make sure minting is open
        m1z.setMintOpen(true);
        
        // Deploy M1ZDestinationMinter
        destinationMinter = new MockM1ZDestinationMinter(
            owner,
            address(0x999),  // router address
            address(m1z)
        );
        
        // Grant CROSS_CHAIN_ROLE to the destination minter
        m1z.grantRole(CROSS_CHAIN_ROLE, address(destinationMinter));
        
        // Configure supported chains
        uint64[] memory supportedChains = new uint64[](1);
        supportedChains[0] = sourceChainSelector;
        destinationMinter.setSupportedChainSelectors(supportedChains, true);
        
        // Configure authorized senders
        bytes[] memory authorizedSenders = new bytes[](1);
        authorizedSenders[0] = senderAddress;
        destinationMinter.setAuthorizedSenders(authorizedSenders, true);
    }
    
    // Test configuration functions
    function testSetM1ZAddress() public {
        address newM1Z = address(0xABC);
        destinationMinter.setM1ZAddress(newM1Z);
        assertEq(destinationMinter.m1zAddress(), newM1Z);
    }
    
    function testSetSupportedChainSelectors() public {
        uint64 newChainSelector = 2;
        uint64[] memory chainSelectors = new uint64[](1);
        chainSelectors[0] = newChainSelector;
        
        destinationMinter.setSupportedChainSelectors(chainSelectors, true);
        assertTrue(destinationMinter.supportedChainSelectors(newChainSelector));
        
        destinationMinter.setSupportedChainSelectors(chainSelectors, false);
        assertFalse(destinationMinter.supportedChainSelectors(newChainSelector));
    }
    
    function testSetAuthorizedSenders() public {
        bytes memory newSender = abi.encode(address(0xDEF));
        bytes[] memory senders = new bytes[](1);
        senders[0] = newSender;
        
        destinationMinter.setAuthorizedSenders(senders, true);
        assertTrue(destinationMinter.authorizedSenders(newSender));
        
        destinationMinter.setAuthorizedSenders(senders, false);
        assertFalse(destinationMinter.authorizedSenders(newSender));
    }
    
    // Test receiving mint message
    function testReceiveMintMessage() public {
        uint256 mintAmount = 2;
        address recipient = user;
        
        // Create a mint message
        bytes memory mintData = abi.encodeWithSignature("mint(uint256,address)", mintAmount, recipient);
        CCIPClient.Any2EVMMessage memory message = CCIPClient.Any2EVMMessage({
            messageId: bytes32(uint256(1)),
            sourceChainSelector: sourceChainSelector,
            sender: senderAddress,
            data: mintData,
            tokenAmounts: new bytes[](0)
        });
        
        // Track initial balance
        uint256 initialBalance = m1z.balanceOf(recipient);
        
        // Expect the CCIPReceived event
        vm.expectEmit(false, false, false, false);
        emit CCIPReceived(message.messageId, message.sourceChainSelector, address(0));
        
        // Process the message
        bool success = destinationMinter.ccipReceive(message);
        
        // Check successful processing
        assertTrue(success);
        
        // Check that tokens were minted
        assertEq(m1z.balanceOf(recipient), initialBalance + mintAmount);
    }
    
    // Test receiving cross-chain transfer message
    function testReceiveCrossChainTransferMessage() public {
        // Setup token IDs and metadata IDs
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 10;
        tokenIds[1] = 11;
        
        uint256[] memory ids = new uint256[](2);
        ids[0] = 101;
        ids[1] = 102;
        
        address recipient = user;
        uint256 fromChainId = 5;
        
        // Create a cross-chain transfer message
        bytes memory transferData = abi.encodeWithSignature(
            "mintFromCrossChainTransfer(uint256[],uint256[],address,uint256)",
            tokenIds,
            ids,
            recipient,
            fromChainId
        );
        
        CCIPClient.Any2EVMMessage memory message = CCIPClient.Any2EVMMessage({
            messageId: bytes32(uint256(2)),
            sourceChainSelector: sourceChainSelector,
            sender: senderAddress,
            data: transferData,
            tokenAmounts: new bytes[](0)
        });
        
        // Track initial balance
        uint256 initialBalance = m1z.balanceOf(recipient);
        
        // Expect the CCIPReceived event
        vm.expectEmit(false, false, false, false);
        emit CCIPReceived(message.messageId, message.sourceChainSelector, address(0));
        
        // Process the message
        bool success = destinationMinter.ccipReceive(message);
        
        // Check successful processing
        assertTrue(success);
        
        // Check that tokens were minted
        assertEq(m1z.balanceOf(recipient), initialBalance + 2);
        
        // Check that the specific token IDs were minted
        assertEq(m1z.ownerOf(tokenIds[0]), recipient);
        assertEq(m1z.ownerOf(tokenIds[1]), recipient);
        
        // Check that tokens are marked as revealed
        assertTrue(m1z.revealedTokenIds(tokenIds[0]));
        assertTrue(m1z.revealedTokenIds(tokenIds[1]));
    }
    
    // Test unauthorized chain
    function testRevertWhenChainNotSupported() public {
        uint64 unsupportedChain = 999;
        
        // Create a mint message with unsupported chain
        bytes memory mintData = abi.encodeWithSignature("mint(uint256,address)", 1, user);
        CCIPClient.Any2EVMMessage memory message = CCIPClient.Any2EVMMessage({
            messageId: bytes32(uint256(3)),
            sourceChainSelector: unsupportedChain,
            sender: senderAddress,
            data: mintData,
            tokenAmounts: new bytes[](0)
        });
        
        // Expect revert
        vm.expectRevert("Source chain not supported");
        destinationMinter.ccipReceive(message);
    }
    
    // Test unauthorized sender
    function testRevertWhenSenderNotAuthorized() public {
        bytes memory unauthorizedSender = abi.encode(address(0x999));
        
        // Create a mint message with unauthorized sender
        bytes memory mintData = abi.encodeWithSignature("mint(uint256,address)", 1, user);
        CCIPClient.Any2EVMMessage memory message = CCIPClient.Any2EVMMessage({
            messageId: bytes32(uint256(4)),
            sourceChainSelector: sourceChainSelector,
            sender: unauthorizedSender,
            data: mintData,
            tokenAmounts: new bytes[](0)
        });
        
        // Expect revert
        vm.expectRevert("Sender not authorized");
        destinationMinter.ccipReceive(message);
    }
} 