const { ethers } = require("ethers");

// Configuration
const FUJI_RPC = "https://api.avax-test.network/ext/bc/C/rpc";

// Contract addresses and selectors
const FUJI_SOURCE_SENDER = "0x9ed5b1C684b7142b6E792F39192d10c23cEEe636";
const CORE_TESTNET_CHAIN_SELECTOR = "4264732132125536123";
const RECEIVER_ADDRESS = "0x8476F4973778DCdEF7402Fa82145b69b083cC12d";

// ABI fragment for getTransferFee
const SOURCE_SENDER_ABI = [
  {
    inputs: [
      { name: "tokenIds", internalType: "uint256[]", type: "uint256[]" },
      { name: "ids", internalType: "uint256[]", type: "uint256[]" },
      {
        name: "destinationChainSelector",
        internalType: "uint64",
        type: "uint64",
      },
      { name: "receiver", internalType: "address", type: "address" },
      {
        name: "payFeesIn",
        internalType: "enum M1ZPrices.PayFeesIn",
        type: "uint8",
      },
    ],
    name: "getTransferFee",
    outputs: [{ name: "", internalType: "uint256", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
];

async function main() {
  try {
    // Connect to Fuji
    const fujiProvider = new ethers.providers.JsonRpcProvider(FUJI_RPC);
    const fujiSourceSender = new ethers.Contract(
      FUJI_SOURCE_SENDER,
      SOURCE_SENDER_ABI,
      fujiProvider
    );

    // Prepare parameters with BigNumber
    const tokenIds = [ethers.BigNumber.from("31")];
    const ids = [ethers.BigNumber.from("16")];
    const destinationChainSelector = ethers.BigNumber.from(
      CORE_TESTNET_CHAIN_SELECTOR
    );
    const payFeesIn = 0; // Enum value doesn't need BigNumber

    console.log("Calling getTransferFee with parameters:");
    console.log(
      "- tokenIds:",
      tokenIds.map((bn) => bn.toString())
    );
    console.log(
      "- ids:",
      ids.map((bn) => bn.toString())
    );
    console.log(
      "- destinationChainSelector:",
      destinationChainSelector.toString()
    );
    console.log("- receiver:", RECEIVER_ADDRESS);
    console.log("- payFeesIn:", payFeesIn);

    try {
      // Call getTransferFee correctly with BigNumber values
      const fee = await fujiSourceSender.getTransferFee(
        tokenIds,
        ids,
        destinationChainSelector,
        RECEIVER_ADDRESS,
        payFeesIn
      );

      console.log(
        "\nSuccess! Transfer Fee:",
        ethers.utils.formatEther(fee),
        "ETH"
      );
    } catch (callError) {
      console.error("\nError calling getTransferFee:", callError.message);

      // Check if the error is about UnsupportedDestinationChain
      if (callError.message.includes("0xae236d9c")) {
        console.log("\nThis is an UnsupportedDestinationChain error.");
        console.log(
          "You need to set Core Testnet as an allowed destination first."
        );
        console.log(
          "Run the verifyChainSetup.js script to check allowed destinations."
        );
      }
    }
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
