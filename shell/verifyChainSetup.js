const { ethers } = require("ethers");

// Configuration
const FUJI_RPC = "https://api.avax-test.network/ext/bc/C/rpc";
const CORE_TESTNET_RPC = "https://rpc.test2.btcs.network/";

// Contract addresses
const FUJI_SOURCE_SENDER = "0x9ed5b1C684b7142b6E792F39192d10c23cEEe636";
const CORE_TESTNET_CHAIN_SELECTOR = "4264732132125536123";

// ABI fragment for just the functions we need
const SOURCE_SENDER_ABI = [
  {
    inputs: [{ name: "", internalType: "uint64", type: "uint64" }],
    name: "allowedDestinations",
    outputs: [{ name: "", internalType: "bool", type: "bool" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        name: "_allowedDestinations",
        internalType: "uint64[]",
        type: "uint64[]",
      },
      { name: "isAllowed", internalType: "bool", type: "bool" },
    ],
    name: "setAllowedDestinations",
    outputs: [],
    stateMutability: "nonpayable",
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

    // Check if Core Testnet is an allowed destination
    const isAllowed = await fujiSourceSender.allowedDestinations(
      CORE_TESTNET_CHAIN_SELECTOR
    );

    console.log(
      `Status: Core Testnet chain selector ${CORE_TESTNET_CHAIN_SELECTOR} is ${
        isAllowed ? "allowed" : "NOT allowed"
      } as destination on Fuji`
    );

    if (!isAllowed) {
      console.log(
        "\nTo fix this issue, call setAllowedDestinations with the following parameters:"
      );
      console.log(`- _allowedDestinations: [${CORE_TESTNET_CHAIN_SELECTOR}]`);
      console.log("- isAllowed: true");
      console.log("\nExample transaction data for setAllowedDestinations:");

      // Create transaction data for setAllowedDestinations
      const iface = new ethers.utils.Interface(SOURCE_SENDER_ABI);
      const data = iface.encodeFunctionData("setAllowedDestinations", [
        [CORE_TESTNET_CHAIN_SELECTOR],
        true,
      ]);
      console.log(`${data}`);
    }
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
