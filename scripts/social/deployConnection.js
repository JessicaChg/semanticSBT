// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

    const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogic");
    const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
    console.log(
        `SemanticSBTLogic deployed ,contract address: ${semanticSBTLogicLibrary.address}`
    );


    const contractName = "Connection";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogic: semanticSBTLogicLibrary.address,
        }
    });
    const myContract = await MyContract.deploy();

    await myContract.deployed();
    console.log(
        `${contractName} deployed ,contract address: ${myContract.address}`
    );
    const [owner] = await ethers.getSigners();
    await myContract.initialize(
        owner.address,
        "test_follow",
        "SBT",
        "124",
        "https://7c7sincqgdslhlsfunhcel7xkv777fq4iay54krm32yqjwovxlvq.arweave.net/-L8kNFAw5LOuRaNOIi_3VX__lhxAMd4qLN6xBNnVuus",
        ["Profile"],
        [["following", 3]],
    )
    console.log(` initialize done!`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
