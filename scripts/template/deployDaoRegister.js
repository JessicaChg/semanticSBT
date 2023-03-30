// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {ethers,upgrades} = require("hardhat");

const name = 'Relation Dao Register';
const symbol = 'SBT';
const baseURI = '';
const schemaURI = 'ar://7mRfawDArdDEcoHpiFkmrURYlMSkREwDnK3wYzZ7-x4';
const class_ = ["Contract"];
const predicate_ = [["daoContract", 3]];

async function main() {

    const [owner] = await ethers.getSigners();

    const SemanticSBTLogic = await ethers.getContractFactory("SemanticSBTLogicUpgradeable");
    const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
    console.log(`SemanticSBTLogicUpgradeable deployed ,contract address: ${semanticSBTLogicLibrary.address}`);
    const DaoRegisterLogic = await ethers.getContractFactory("DaoRegisterLogic");
    const daoRegisterLogicLibrary = await DaoRegisterLogic.deploy();
    console.log(`DaoRegisterLogic deployed ,contract address: ${daoRegisterLogicLibrary.address}`);
    const Dao = await ethers.getContractFactory("Dao", {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
        }
    });
    const dao = await Dao.deploy();
    await dao.deployTransaction.wait();
    console.log(`Dao deployed ,contract address: ${dao.address}`);

    const DaoWithSign = await ethers.getContractFactory("DaoWithSign", {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
        }
    });
    const daoWithSignName = "Dao With Sign";
    const daoWithSign = await upgrades.deployProxy(DaoWithSign,
        [daoWithSignName],
        {unsafeAllowLinkedLibraries: true});
    await daoWithSign.deployed();
    await daoWithSign.deployTransaction.wait();
    console.log(`DaoWithSign deployed ,contract address: ${daoWithSign.address}`);


    const contractName = "DaoRegister";
    const MyContract = await ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
            DaoRegisterLogic: daoRegisterLogicLibrary.address,
        }
    });
    const daoRegister = await upgrades.deployProxy(MyContract,
        [owner.address,
            name,
            symbol,
            baseURI,
            schemaURI,
            class_,
            predicate_],
        {unsafeAllowLinkedLibraries: true});

    await daoRegister.deployed();
    console.log(`${contractName} deployed ,contract address: ${daoRegister.address}`);
    await (await daoRegister.setDaoImpl(dao.address)).wait();
    console.log(`${contractName} setDaoImpl successfully!` );
    await (await daoRegister.setDaoVerifyContract(daoWithSign.address)).wait();
    console.log(`${contractName} setDaoVerifyContract successfully!` );
}

// async function main() {
//
// }


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
