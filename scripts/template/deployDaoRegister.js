// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const name = 'Dao Register';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://MaXW2Db8G5EY2LNIR_JoiTqkIB9GUxWvAtN0vzYKl5w';
const class_ = ["Contract"];
const predicate_ = [["daoContract", 3]];

async function main() {

    const [owner] = await ethers.getSigners();

    const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogicUpgradeable");
    const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
    console.log(
        `SemanticSBTLogicUpgradeable deployed ,contract address: ${semanticSBTLogicLibrary.address}`
    );
    const DaoRegisterLogic = await hre.ethers.getContractFactory("DaoRegisterLogic");
    const daoRegisterLogicLibrary = await DaoRegisterLogic.deploy();
    console.log(
        `DaoRegisterLogic deployed ,contract address: ${daoRegisterLogicLibrary.address}`
    );
    const Dao = await hre.ethers.getContractFactory("Dao", {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
        }
    });
    const dao = await Dao.deploy();
    await dao.deployTransaction.wait();
    console.log(
        `Dao deployed ,contract address: ${dao.address}`
    );
    const contractName = "DaoRegister";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
            DaoRegisterLogic: daoRegisterLogicLibrary.address,
        }
    });
    const daoRegister = await MyContract.deploy();
    console.log(
        `${contractName} deployed ,contract address: ${daoRegister.address}`
    );
    await (await daoRegister.initialize(
        owner.address,
        name,
        symbol,
        baseURI,
        schemaURI,
        class_,
        predicate_)).wait();
    console.log(
        `${contractName} initialized!`
    );

    await (await daoRegister.setDaoImpl(dao.address)).wait();
    console.log(
        `${contractName} setDaoImpl successfully!`
    );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
