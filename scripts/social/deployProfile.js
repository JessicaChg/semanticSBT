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

    const ProfileLogic = await hre.ethers.getContractFactory("ProfileLogic");
    const profileLogicLibrary = await ProfileLogic.deploy();
    console.log(`ProfileLogic deployed ,contract address: ${profileLogicLibrary.address}`);


    const contractName = "Profile";
    const MyContract = await hre.ethers.getContractFactory(contractName, {
        libraries: {
            SemanticSBTLogic: semanticSBTLogicLibrary.address,
            DeployConnection: deployConnectionLibrary.address,
            InitializeConnection: initializeConnectionLibrary.address,
            ProfileLogic: profileLogicLibrary.address
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
        "test",
        "SBT",
        "124",
        "https://3f6th2sfh2yso3fa3datuzpn3ijodwomvduai7yvj5ifxujebujq.arweave.net/2X0z6kU-sSdsoNjBOmXt2hLh2cyo6AR_FU9QW9EkDRM",
        ["Profile", "Contract"],
        [["owner", 3], ["name", 1], ["avatar", 1], ["connectionAddress", 3]],
    )
    console.log(` initialize done!`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
