// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const {ethers, upgrades} = require("hardhat");

const name = 'Relation Follow Register';
const symbol = 'SBT';
const baseURI = '';
const schemaURI = 'ar://auPfoCDBtJ3RJ_WyUqV9O7GAARDzkUT4TSuj9uuax-0';
const class_ = ["Contract"];
const predicate_ = [["followContract", 3]];

async function main() {

    const [owner] = await ethers.getSigners();

    const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogicUpgradeable");
    const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
    console.log(
        `SemanticSBTLogicUpgradeable deployed ,contract address: ${semanticSBTLogicLibrary.address}`
    );
    const FollowRegisterLogic = await hre.ethers.getContractFactory("FollowRegisterLogic");
    const followRegisterLogicLibrary = await FollowRegisterLogic.deploy();
    console.log(
        `FollowRegisterLogic deployed ,contract address: ${followRegisterLogicLibrary.address}`
    );
    const Follow = await hre.ethers.getContractFactory("Follow", {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
        }
    });
    const follow = await Follow.deploy();
    await follow.deployTransaction.wait();
    console.log(
        `Follow deployed ,contract address: ${follow.address}`
    );
    const UpgradeableBeacon = await hre.ethers.getContractFactory("UpgradeableBeacon");
    const upgradeableBeacon = await UpgradeableBeacon.deploy(follow.address);
    await upgradeableBeacon.deployTransaction.wait();
    console.log(
        `UpgradeableBeacon deployed ,contract address: ${upgradeableBeacon.address}`
    );

    const FollowWithSign = await hre.ethers.getContractFactory("FollowWithSign", {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
        }
    });
    const followWithSignName = "Follow With Sign";
    const followWithSign = await upgrades.deployProxy(FollowWithSign,
        [followWithSignName],
        {unsafeAllowLinkedLibraries: true});
    await followWithSign.deployed();
    await followWithSign.deployTransaction.wait();
    console.log(`FollowWithSign deployed ,contract address: ${followWithSign.address}`);


    const contractName = "FollowRegister";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
            FollowRegisterLogic: followRegisterLogicLibrary.address,
        }
    });
    const followRegister = await upgrades.deployProxy(MyContract,
        [owner.address,
            name,
            symbol,
            baseURI,
            schemaURI,
            class_,
            predicate_],
        {unsafeAllowLinkedLibraries: true});

    await followRegister.deployed();
    console.log(
        `${contractName} deployed ,contract address: ${followRegister.address}`
    );
    await (await followRegister.setFollowImpl(upgradeableBeacon.address)).wait();
    console.log(
        `${contractName} setFollowImpl successfully!`
    );

    await (await followRegister.setFollowVerifyContract(followWithSign.address)).wait();
    console.log(
        `${contractName} setFollowVerifyContract successfully!`
    );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
