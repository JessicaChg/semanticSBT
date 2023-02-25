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
    const DeployConnection = await hre.ethers.getContractFactory("DeployConnection", {
        libraries: {
            SemanticSBTLogic: semanticSBTLogicLibrary.address,
        }
    });
    const deployConnectionLibrary = await DeployConnection.deploy();
    console.log(
        `DeployConnection deployed ,contract address: ${deployConnectionLibrary.address}`
    );

    const InitializeConnection = await hre.ethers.getContractFactory("InitializeConnection");
    const initializeConnectionLibrary = await InitializeConnection.deploy();
    console.log(`InitializeConnection deployed ,contract address: ${initializeConnectionLibrary.address}`);


    const contractName = "FollowRegister";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogic: semanticSBTLogicLibrary.address,
            DeployConnection: deployConnectionLibrary.address,
            InitializeConnection: initializeConnectionLibrary.address,
        }
    });
    const connectionRegister = await MyContract.deploy();

    await connectionRegister.initialize(
        owner.address,
        name,
        symbol,
        baseURI,
        schemaURI,
        class_,
        predicate_);
    console.log(
        `${contractName} deployed ,contract address: ${connectionRegister.address}`
    );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
