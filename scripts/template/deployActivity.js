// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const name = 'Activity Template';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://pEaI9o8moBFof5IkOSq1qNnl8RuP0edn2BFD1q6vdE4';
const class_ = ["Activity"];
const predicate_ = [["participate", 3]];
const myActivity = "Example-Activity";

async function main() {

    const [owner] = await ethers.getSigners();

    const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogic");
    const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
    console.log(`SemanticSBTLogic deployed ,contract address: ${semanticSBTLogicLibrary.address}`);

    const contractName = "Activity";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogic: semanticSBTLogicLibrary.address,
        }
    });
    const myContract = await MyContract.deploy();
    console.log(`${contractName} deployed ,contract address: ${myContract.address}`);
    await myContract.deployTransaction.wait();

    await (await myContract.initialize(
        owner.address,
        name,
        symbol,
        baseURI,
        schemaURI,
        class_,
        predicate_)).wait();
    console.log(`${contractName} initialized!`);


    await myContract.addSubject(
        myActivity,
        "Activity"
    );
    console.log(`${myActivity} has added to ${contractName}`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
