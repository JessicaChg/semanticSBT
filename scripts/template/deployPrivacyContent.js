// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const {ethers, upgrades} = require("hardhat");


const name = 'Privacy Content';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://DeM6LRONjAUYr3qixkguLuFvYSHkykN7ZRKHn2HR5Gs';
const class_ = [];
const predicate_ = [["privacyContent", 1]];


async function main() {
    const [owner] = await ethers.getSigners();

    const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogicUpgradeable");
    const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
    console.log(`SemanticSBTLogic deployed ,contract address: ${semanticSBTLogicLibrary.address}`);

    const PrivacyContentWithSign = await hre.ethers.getContractFactory("PrivacyContentWithSign", {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
        }
    });
    const privacyContentWithSignName = "Privacy Content With Sign";
    const privacyContentWithSign = await upgrades.deployProxy(PrivacyContentWithSign,
        [privacyContentWithSignName],
        {unsafeAllowLinkedLibraries: true});
    await privacyContentWithSign.deployed();
    await privacyContentWithSign.deployTransaction.wait();
    console.log(`PrivacyContentWithSign deployed ,contract address: ${privacyContentWithSign.address}`);


    const contractName = "PrivacyContent";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
        }
    });
    const privacyContentContract = await upgrades.deployProxy(MyContract,
        [owner.address,
            privacyContentWithSign.address,
            name,
            symbol,
            baseURI,
            schemaURI,
            class_,
            predicate_],
        {unsafeAllowLinkedLibraries: true, initializer: 'initialize(address, address, string, string, string, string, string[], (string,uint8)[])'});

    await privacyContentContract.deployed();
    console.log(
        `${contractName} deployed ,contract address: ${privacyContentContract.address}`
    );


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
