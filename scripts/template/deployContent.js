// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const {ethers, upgrades} = require("hardhat");

const name = 'Relation Content';
const symbol = 'SBT';
const baseURI = '';
const schemaURI = 'ar://HENWTh3esXyAeLe1Yg_BrBOHhW-CcDQoU5inaAx-yNs';
const class_ = [];
const predicate_ = [["publicContent", 1]];


async function main() {
    const [owner] = await ethers.getSigners();

    const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogicUpgradeable");
    const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
    console.log(`SemanticSBTLogic deployed ,contract address: ${semanticSBTLogicLibrary.address}`);

    const ContentWithSign = await hre.ethers.getContractFactory("ContentWithSign", {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
        }
    });
    const contentWithSignName = "Content With Sign";
    const contentWithSign = await upgrades.deployProxy(ContentWithSign,
        [contentWithSignName],
        {unsafeAllowLinkedLibraries: true});
    await contentWithSign.deployed();
    await contentWithSign.deployTransaction.wait();
    console.log(`ContentWithSign deployed ,contract address: ${contentWithSign.address}`);

    const contractName = "Content";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
        }
    });


    const contentContract = await upgrades.deployProxy(MyContract,
        [owner.address,
            contentWithSign.address,
            name,
            symbol,
            baseURI,
            schemaURI,
            class_,
            predicate_],
        {unsafeAllowLinkedLibraries: true, initializer: 'initialize(address, address, string, string, string, string, string[], (string,uint8)[])'});

    await contentContract.deployed();
    console.log(
        `${contractName} deployed ,contract address: ${contentContract.address}`
    );


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
