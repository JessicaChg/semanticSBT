// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const name = 'Name Service';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://Za2Zvs8bYMKqqS0dfvA1M5g_qkQzyM1nkKG32RWv_9Q';
const class_ = ["Domain"];
const predicate_ = [["hold", 3], ["resolved", 3]];

async function main() {

  const [owner] = await ethers.getSigners();

  const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogic");
  const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
  console.log(
      `SemanticSBTLogic deployed ,contract address: ${semanticSBTLogicLibrary.address}`
  );

  const contractName = "NameService";
  const MyContract = await hre.ethers.getContractFactory(contractName, {
    libraries: {
      SemanticSBTLogic: semanticSBTLogicLibrary.address,
    }
  });
  const nameService = await MyContract.deploy();

  await nameService.initialize(
      owner.address,
      name,
      symbol,
      baseURI,
      schemaURI,
      class_,
      predicate_);
  console.log(
    `${contractName} deployed ,contract address: ${nameService.address}`
  );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
