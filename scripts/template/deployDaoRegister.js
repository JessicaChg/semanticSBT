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

    const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogic");
    const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
    console.log(
        `SemanticSBTLogic deployed ,contract address: ${semanticSBTLogicLibrary.address}`
    );
    const DeployDao = await hre.ethers.getContractFactory("DeployDao", {
        libraries: {
            SemanticSBTLogic: semanticSBTLogicLibrary.address,
        }
    });
    const deployDaoLibrary = await DeployDao.deploy();
    console.log(
        `DeployDao deployed ,contract address: ${deployDaoLibrary.address}`
    );

    const InitializeDao = await hre.ethers.getContractFactory("InitializeDao");
    const initializeDaoLibrary = await InitializeDao.deploy();
    console.log(`InitializeDao deployed ,contract address: ${initializeDaoLibrary.address}`);


    const contractName = "DaoRegister";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogic: semanticSBTLogicLibrary.address,
            DeployDao: deployDaoLibrary.address,
            InitializeDao: initializeDaoLibrary.address,
        }
    });
    const daoRegister = await MyContract.deploy();

    await daoRegister.initialize(
        owner.address,
        name,
        symbol,
        baseURI,
        schemaURI,
        class_,
        predicate_);
    console.log(
        `${contractName} deployed ,contract address: ${daoRegister.address}`
    );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
