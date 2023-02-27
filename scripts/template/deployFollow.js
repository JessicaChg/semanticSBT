// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const name = "Bob's Connection Template";
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://5WULgp7dEkBShlT37fKXpyr0tSLyS2xXdYw8VHf06MY';
const class_ = [];
const predicate_ = [["following", 3]];

async function main() {

  const [owner,addr1] = await ethers.getSigners();

  const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogic");
  const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
  console.log(
      `SemanticSBTLogic deployed ,contract address: ${semanticSBTLogicLibrary.address}`
  );

  const contractName = "Follow";
  const MyContract = await hre.ethers.getContractFactory(contractName, {
    libraries: {
      SemanticSBTLogic: semanticSBTLogicLibrary.address,
    }
  });
  const follow = await MyContract.deploy();
  await follow.deployTransaction.wait();
  console.log(
      `Follow deployed ,contract address: ${follow.address}`
  );
  await follow.init(
      owner.address,
      owner.address,
      name,
      symbol,
      baseURI,
      schemaURI,
      class_,
      predicate_);
  console.log(
    `${contractName} initialize successfully!`
  );

  await follow.connect(addr1).follow()
  console.log(`${addr1.address} following  ${owner.address} successfully!`);

  const rdf = await follow.rdfOf(1);
  console.log(`The rdf of the first token is:  ${rdf}`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
