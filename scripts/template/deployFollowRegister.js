// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const name = 'Follow Register Template';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://pvP6VX-gLwgdeeR5SOsctAkIp8WtO2BhqEZ1SYdUJtU';
const class_ = ["Contract"];
const predicate_ = [["followContract", 3]];

async function main() {

    const [owner] = await ethers.getSigners();

    const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogic");
    const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
    console.log(
        `SemanticSBTLogic deployed ,contract address: ${semanticSBTLogicLibrary.address}`
    );
    const DeployFollow = await hre.ethers.getContractFactory("DeployFollow", {
        libraries: {
            SemanticSBTLogic: semanticSBTLogicLibrary.address,
        }
    });
    const deployFollowLibrary = await DeployFollow.deploy();
    console.log(
        `DeployFollow deployed ,contract address: ${deployFollowLibrary.address}`
    );

    const InitializeFollow = await hre.ethers.getContractFactory("InitializeFollow");
    const initializeFollowLibrary = await InitializeFollow.deploy();
    console.log(`InitializeFollow deployed ,contract address: ${initializeFollowLibrary.address}`);


    const contractName = "FollowRegister";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogic: semanticSBTLogicLibrary.address,
            DeployFollow: deployFollowLibrary.address,
            InitializeFollow: initializeFollowLibrary.address,
        }
    });
    const followRegister = await MyContract.deploy();

    await (await followRegister.initialize(
        owner.address,
        name,
        symbol,
        baseURI,
        schemaURI,
        class_,
        predicate_)).wait();
    console.log(
        `${contractName} deployed ,contract address: ${followRegister.address}`
    );


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
