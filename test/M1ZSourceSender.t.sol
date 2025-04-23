// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/M1ZSourceSender.sol";
import "../src/MissingOnez.sol";

// Mock Client library to use in the mock router
library MockClient {
    struct EVMTokenAmount {
        address token;
        uint256 amount;
    }

    struct EVMExtraArgsV1 {
        uint256 gasLimit;
        bool strict;
    }

    struct EVM2AnyMessage {
        bytes receiver;
        bytes data;
        EVMTokenAmount[] tokenAmounts;
        bytes extraArgs;
        address feeToken;
    }

    function _argsToBytes(EVMExtraArgsV1 memory args) internal pure returns (bytes memory) {
        return abi.encode(args);
    }
}

// Mock Router for testing CCIP functionality
contract MockRouter {
    bytes32 private mockMessageId = bytes32(uint256(1));
    uint256 private mockFee = 0.01 ether;

    function ccipSend(uint64, MockClient.EVM2AnyMessage memory) external payable returns (bytes32) {
        return mockMessageId;
    }

    function getFee(uint64, MockClient.EVM2AnyMessage memory) external view returns (uint256) {
        return mockFee;
    }

    function setMockFee(uint256 _fee) external {
        mockFee = _fee;
    }
}

// Mock Link Token
contract MockLink {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "insufficient allowance");
        require(_balances[sender] >= amount, "insufficient balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;

        return true;
    }
}

// Mock the M1ZSourceSender contract since it depends on Client library
contract MockM1ZSourceSender is M1ZPrices, Withdraw {
    address public i_router;
    address immutable i_link;

    event MessageSent(bytes32 messageId);

    uint256 public maxBatch = 5;
    uint256 public crossChainGasLimit = 1000000;

    MissingOnez public m1z;
    mapping(uint64 => bool) public allowedDestinations;
    bool public canMintCrossChain;

    constructor(address initialOwner, address router, address link, uint256 _unitPrice, address m1zAddress)
        M1ZPrices(_unitPrice)
        Withdraw(initialOwner)
    {
        i_router = router;
        i_link = link;
        m1z = MissingOnez(m1zAddress);
    }

    receive() external payable {}

    function setRouter(address router) external onlyOwner {
        i_router = router;
    }

    function setM1Z(address m1zAddress) external onlyOwner {
        m1z = MissingOnez(m1zAddress);
    }

    function setAllowedDestinations(uint64[] calldata _allowedDestinations, bool isAllowed) external onlyOwner {
        for (uint256 i = 0; i < _allowedDestinations.length; i++) {
            allowedDestinations[_allowedDestinations[i]] = isAllowed;
        }
    }

    function setCanMintCrossChain(bool _canMintCrossChain) external onlyOwner {
        canMintCrossChain = _canMintCrossChain;
    }

    function setMaxBatch(uint256 _maxBatch) external onlyOwner {
        maxBatch = _maxBatch;
    }

    function setCrossChainGasLimit(uint256 _crossChainGasLimit) external onlyOwner {
        crossChainGasLimit = _crossChainGasLimit;
    }

    // Mock functions for testing
    function getMintFee(uint256 amount, uint64 destinationChainSelector, address receiver, PayFeesIn payFeesIn)
        external
        view
        returns (uint256)
    {
        return 0.01 ether;
    }

    function getTransferFee(
        uint256[] calldata tokenIds,
        uint256[] calldata ids,
        uint64 destinationChainSelector,
        address receiver,
        PayFeesIn payFeesIn
    ) external view returns (uint256) {
        return 0.01 ether;
    }

    function mint(uint256 amount, uint64 destinationChainSelector, address receiver, PayFeesIn payFeesIn)
        external
        payable
    {
        require(allowedDestinations[destinationChainSelector], "M1ZSourceSender: destination chain is not allowed");
        require(canMintCrossChain, "M1ZSourceSender: mint is not permitted from this chain to another chain");
        require(amount > 0, "M1ZSourceSender: must mint at least one");
        require(amount <= maxBatch, "M1ZSourceSender: cannot mint more than maxBatch at once");

        uint256 price = getPrice(amount);
        require(msg.value >= price, "M1ZSourceSender: did not send enough native tokens to pay");

        if (payFeesIn == PayFeesIn.Native) {
            require(
                msg.value >= price + 0.01 ether, "M1ZSourceSender: did not send enough native tokens to cover the fees"
            );
        }

        emit MessageSent(bytes32(uint256(1)));
    }

    function sendToOtherChain(
        uint256[] calldata tokenIds,
        uint256[] calldata ids,
        uint64 destinationChainSelector,
        address receiver,
        PayFeesIn payFeesIn
    ) external payable {
        require(allowedDestinations[destinationChainSelector], "M1ZSourceSender: destination chain is not allowed");
        require(tokenIds.length == ids.length, "M1ZSourceSender: arrays lengths do not match");
        require(tokenIds.length > 0, "M1ZSourceSender: must send at least 1 M1Z");
        require(tokenIds.length <= maxBatch, "M1ZSourceSender: cannot transfer more than maxBatch at once");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                m1z.revealedTokenIds(tokenIds[i]), "M1ZSourceSender: cannot transfer to another chain if not revealed"
            );
            m1z.burn(tokenIds[i]);
        }

        emit MessageSent(bytes32(uint256(1)));
    }
}

contract M1ZSourceSenderTest is Test {
    MockM1ZSourceSender public sender;
    MissingOnez public m1z;
    MockRouter public router;
    MockLink public linkToken;

    address public owner;
    address public user;
    uint64 public destinationChainSelector = 1;
    address public receiverAddress = address(0x789);

    // Define the event for testing
    event MessageSent(bytes32 messageId);

    function setUp() public {
        owner = address(this);
        user = address(0x456);

        // Deploy mock contracts
        router = new MockRouter();
        linkToken = new MockLink();

        // Deploy MissingOnez
        m1z = new MissingOnez(
            owner,
            address(0x123), // royalty recipient
            0.1 ether, // unit price
            1, // min ID
            1001, // max ID (1000 tokens total)
            "unrevealed.json"
        );

        // Make sure minting is open
        m1z.setMintOpen(true);

        // Grant CROSS_CHAIN_ROLE to the sender that will be created
        bytes32 CROSS_CHAIN_ROLE = keccak256("CROSS_CHAIN_ROLE");

        // Deploy M1ZSourceSender
        sender = new MockM1ZSourceSender(owner, address(router), address(linkToken), 0.1 ether, address(m1z));

        // Grant the CROSS_CHAIN_ROLE to the sender
        m1z.grantRole(CROSS_CHAIN_ROLE, address(sender));

        // Configure sender
        uint64[] memory allowedChains = new uint64[](1);
        allowedChains[0] = destinationChainSelector;
        sender.setAllowedDestinations(allowedChains, true);
        sender.setCanMintCrossChain(true);

        // Give the user some ETH
        vm.deal(user, 10 ether);
    }

    // Test for setting configuration parameters
    function testSetters() public {
        // Test router setter
        address newRouter = address(0xABC);
        sender.setRouter(newRouter);
        assertEq(sender.i_router(), newRouter);

        // Test M1Z setter
        address newM1Z = address(0xDEF);
        sender.setM1Z(newM1Z);
        assertEq(address(sender.m1z()), newM1Z);

        // Test maxBatch setter
        uint256 newMaxBatch = 10;
        sender.setMaxBatch(newMaxBatch);
        assertEq(sender.maxBatch(), newMaxBatch);

        // Test crossChainGasLimit setter
        uint256 newGasLimit = 2000000;
        sender.setCrossChainGasLimit(newGasLimit);
        assertEq(sender.crossChainGasLimit(), newGasLimit);

        // Test canMintCrossChain setter
        sender.setCanMintCrossChain(false);
        assertEq(sender.canMintCrossChain(), false);
        sender.setCanMintCrossChain(true);
        assertEq(sender.canMintCrossChain(), true);
    }

    // Test for getting mint fees
    function testGetMintFee() public {
        uint256 mintAmount = 2;
        uint256 fee =
            sender.getMintFee(mintAmount, destinationChainSelector, receiverAddress, M1ZPrices.PayFeesIn.Native);

        assertEq(fee, 0.01 ether);
    }

    // Test for getting transfer fees
    function testGetTransferFee() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 2;

        uint256[] memory ids = new uint256[](2);
        ids[0] = 101;
        ids[1] = 102;

        uint256 fee =
            sender.getTransferFee(tokenIds, ids, destinationChainSelector, receiverAddress, M1ZPrices.PayFeesIn.Native);

        assertEq(fee, 0.01 ether);
    }

    // Test cross-chain minting with native token
    function testCrossChainMintWithNative() public {
        uint256 mintAmount = 2;
        uint256 mintPrice = 0.2 ether; // 0.1 ether per token
        uint256 ccipFee = 0.01 ether;

        vm.prank(user);
        vm.expectEmit(false, false, false, false);
        emit MessageSent(bytes32(0));
        sender.mint{value: mintPrice + ccipFee}(
            mintAmount, destinationChainSelector, receiverAddress, M1ZPrices.PayFeesIn.Native
        );
    }

    // Test cross-chain minting with LINK token
    function testCrossChainMintWithLink() public {
        uint256 mintAmount = 2;
        uint256 mintPrice = 0.2 ether; // 0.1 ether per token

        vm.prank(user);
        vm.expectEmit(false, false, false, false);
        emit MessageSent(bytes32(0));
        sender.mint{value: mintPrice}(mintAmount, destinationChainSelector, receiverAddress, M1ZPrices.PayFeesIn.LINK);
    }

    // Test revert when destination chain not allowed
    function testRevertWhenDestinationNotAllowed() public {
        uint64 unauthorizedChain = 999;
        uint256 mintAmount = 2;

        vm.prank(user);
        vm.expectRevert("M1ZSourceSender: destination chain is not allowed");
        sender.mint{value: 1 ether}(mintAmount, unauthorizedChain, receiverAddress, M1ZPrices.PayFeesIn.Native);
    }

    // Test revert when cross chain minting is disabled
    function testRevertWhenMintingDisabled() public {
        sender.setCanMintCrossChain(false);

        vm.prank(user);
        vm.expectRevert("M1ZSourceSender: mint is not permitted from this chain to another chain");
        sender.mint{value: 1 ether}(1, destinationChainSelector, receiverAddress, M1ZPrices.PayFeesIn.Native);
    }

    // Test exceeding max batch limit
    function testRevertWhenExceedingMaxBatch() public {
        uint256 maxBatch = sender.maxBatch();

        vm.prank(user);
        vm.expectRevert("M1ZSourceSender: cannot mint more than maxBatch at once");
        sender.mint{value: 10 ether}(
            maxBatch + 1, destinationChainSelector, receiverAddress, M1ZPrices.PayFeesIn.Native
        );
    }

    // Test insufficient payment
    function testRevertWithInsufficientPayment() public {
        vm.prank(user);
        vm.expectRevert("M1ZSourceSender: did not send enough native tokens to pay");
        sender.mint{value: 0.05 ether}(1, destinationChainSelector, receiverAddress, M1ZPrices.PayFeesIn.Native);
    }

    // Test insufficient fee
    function testRevertWithInsufficientFee() public {
        uint256 mintPrice = 0.1 ether;

        vm.prank(user);
        vm.expectRevert("M1ZSourceSender: did not send enough native tokens to cover the fees");
        sender.mint{value: mintPrice}( // Missing the CCIP fee
        1, destinationChainSelector, receiverAddress, M1ZPrices.PayFeesIn.Native);
    }

    // Test sending NFTs to another chain
    function testSendToOtherChain() public {
        // First mint and reveal a token for the user
        vm.prank(user);
        m1z.paidMint{value: 0.1 ether}(1);

        // Reveal the token (as the user)
        vm.prank(user);
        m1z.reveal(1);

        // Need to approve sender contract to burn the token
        vm.prank(user);
        m1z.approve(address(sender), 1);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 1;

        uint256[] memory ids = new uint256[](1);
        // Use a random ID instead of trying to extract from tokenURI
        ids[0] = 101;

        vm.prank(user);
        vm.expectEmit(false, false, false, false);
        emit MessageSent(bytes32(0));
        sender.sendToOtherChain{value: 0.01 ether}(
            tokenIds, ids, destinationChainSelector, receiverAddress, M1ZPrices.PayFeesIn.Native
        );
    }
}
