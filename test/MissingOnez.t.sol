// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MissingOnez.sol";

contract MissingOnezTest is Test {
    MissingOnez public m1z;
    address public owner;
    address public royaltyRecipient;
    address public user;
    
    function setUp() public {
        owner = address(this);
        royaltyRecipient = address(0x123);
        user = address(0x456);
        
        m1z = new MissingOnez(
            owner,
            royaltyRecipient,
            0.1 ether,  // unit price
            1,          // min ID
            1001,       // max ID (1000 tokens total)
            "unrevealed.json"
        );
        
        // Open minting for most tests
        m1z.setMintOpen(true);
        
        // Give the user some ETH
        vm.deal(user, 10 ether);
    }
    
    function testBaseURI() public view {
        assertEq(m1z.baseURI(), "https://cdn.madskullz.io/missingonez/metadata/");
    }
    
    function testSetBaseURI() public {
        string memory newURI = "https://newuri.com/";
        m1z.setBaseUri(newURI);
        assertEq(m1z.baseURI(), newURI);
    }
    
    function testMintClosed() public {
        // Close minting
        m1z.setMintOpen(false);
        assertEq(m1z.isMintOpen(), false);
        
        // Try to mint when closed
        vm.prank(user);
        vm.expectRevert("M1Z: mint is not open");
        m1z.paidMint(1);
    }
    
    function testMintOpen() public {
        // Mint a token
        vm.prank(user);
        m1z.paidMint{value: 0.1 ether}(1);
        
        // Check ownership
        assertEq(m1z.balanceOf(user), 1);
        assertEq(m1z.ownerOf(1), user);
    }
    
    function testMaxSupply() public view {
        assertEq(m1z.maxSupply(), 1000);
    }
    
    function testSupplyLeft() public {
        // Initially all supply is left
        assertEq(m1z.supplyLeft(), 1000);
        
        // Mint a token
        vm.prank(user);
        m1z.paidMint{value: 0.1 ether}(1);
        
        // Check updated supply
        assertEq(m1z.supplyLeft(), 999);
    }
    
    function testBatchMint() public {
        // Mint 5 tokens at once
        vm.prank(user);
        m1z.paidMint{value: 0.5 ether}(5);
        
        // Check ownership
        assertEq(m1z.balanceOf(user), 5);
        for (uint256 i = 1; i <= 5; i++) {
            assertEq(m1z.ownerOf(i), user);
        }
        
        // Check supply left
        assertEq(m1z.supplyLeft(), 995);
    }
    
    function testMaxBatchMintLimit() public {
        // Try to mint more than MAX_BATCH_MINT (10)
        vm.prank(user);
        vm.expectRevert("M1Z: cannot mint more than MAX_BATCH_MINT at once");
        m1z.paidMint{value: 1.1 ether}(11);
    }
    
    function testInsufficientPayment() public {
        // Try to mint with insufficient payment
        vm.prank(user);
        vm.expectRevert("M1Z: did not send enough native tokens");
        m1z.paidMint{value: 0.05 ether}(1);
    }
    
    function testReveal() public {
        // First mint a token
        vm.prank(user);
        m1z.paidMint{value: 0.1 ether}(1);
        
        // Check it's not revealed yet
        assertEq(m1z.revealedTokenIds(1), false);
        
        // Reveal the token
        vm.prank(user);
        m1z.reveal(1);
        
        // Check it's now revealed
        assertEq(m1z.revealedTokenIds(1), true);
    }
    
    function testAutoReveal() public {
        // First mint a token
        vm.prank(user);
        m1z.paidMint{value: 0.1 ether}(1);
        
        // Check it's not revealed yet
        assertEq(m1z.revealedTokenIds(1), false);
        
        // Auto reveal the token (owner only)
        m1z.autoReveal(1);
        
        // Check it's now revealed
        assertEq(m1z.revealedTokenIds(1), true);
    }
    
    function testNonOwnerCannotAutoReveal() public {
        // First mint a token
        vm.prank(user);
        m1z.paidMint{value: 0.1 ether}(1);
        
        // Try to auto reveal from non-owner address
        vm.prank(user);
        vm.expectRevert();
        m1z.autoReveal(1);
    }
    
    function testRevealAlreadyRevealed() public {
        // First mint a token
        vm.prank(user);
        m1z.paidMint{value: 0.1 ether}(1);
        
        // Reveal the token
        vm.prank(user);
        m1z.reveal(1);
        
        // Try to reveal again
        vm.prank(user);
        vm.expectRevert("M1Z: already revealed");
        m1z.reveal(1);
    }
    
    function testTokenURI() public {
        // First mint a token
        vm.prank(user);
        m1z.paidMint{value: 0.1 ether}(1);
        
        // Check unrevealed URI
        string memory unrevealedURI = string(abi.encodePacked(m1z.baseURI(), m1z.unrevealedPath()));
        vm.prank(user);
        assertEq(m1z.tokenURI(1), unrevealedURI);
        
        // Reveal the token
        vm.prank(user);
        m1z.reveal(1);
        
        // Note: We can't easily test the exact tokenURI because it depends on the random ID
        // but we can at least make sure it's a different string than before
        vm.prank(user);
        string memory revealedURI = m1z.tokenURI(1);
        assertTrue(keccak256(bytes(revealedURI)) != keccak256(bytes(unrevealedURI)));
    }
} 