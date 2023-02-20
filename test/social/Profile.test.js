/*
* These cases are for testing the methods of Semantic SBT demo contract
*/
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const {expect} = require("chai");
const {MerkleTree} = require('merkletreejs');
const keccak256 = require('keccak256');
var Web3 = require('web3');
const hre = require("hardhat");

const name = 'privacy example SBT';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'https://3f6th2sfh2yso3fa3datuzpn3ijodwomvduai7yvj5ifxujebujq.arweave.net/2X0z6kU-sSdsoNjBOmXt2hLh2cyo6AR_FU9QW9EkDRM';
const class_ = ["Profile","Contract"];
const predicate_ = [["owner",3],["name",1],["avatar",1],["nostr",1],["connectionAddress",3]];



/*
* Before Mint SBT, should initial the parameters of this contract. In this step, we prepare the element of semantic SBT
* @param name The name for the Semantic SBT
* @param symbol The symbol for the Semantic SBT
* @param baseURI The URI may point to a JSON file that conforms to the "ERC721Metadata JSON Schema".
* @param schemaURI The URI of the contract witch point to a JSON file that conforms to the "ISemanticMetadata Metadata JSON Schema".
* @param [className] The array of class name which are used for define the "SUBJECT" of SPO 
* @param [className] The array of five data types of predicates which are used for define the "PREDICATE" of SPO 
*/
describe("Profile contract", function () {
    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();

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
        const profile = await MyContract.deploy();

        await profile.initialize(
            owner.address,
            name,
            symbol,
            baseURI,
            schemaURI,
            class_,
            predicate_);
        return {profile, owner, addr1, addr2};
    }

    // check semanticSBT belong this contract owner
    it("owner", async function () {
        const {profile, owner} = await loadFixture(deployTokenFixture);
        expect(await profile.owner()).to.equal(owner.address);
    });
    // make sure contract owner can mint SBT
    it("minter", async function () {
        const {profile, owner} = await loadFixture(deployTokenFixture);
        expect(await profile.minters(owner.address)).to.equal(true);
    });

    // make sure the name of semantic SBT setup up as expected
    it("name", async function () {
        const {profile} = await loadFixture(deployTokenFixture);
        expect(await profile.name()).to.equal(name);
    });

    // make sure the symbol of semantic SBT setup up as expected
    it("symbol", async function () {
        const {profile} = await loadFixture(deployTokenFixture);
        expect(await profile.symbol()).to.equal(symbol);
    });

    // make sure the schemaURI of semantic SBT setup up as expected
    it("schemaURI", async function () {
        const {profile} = await loadFixture(deployTokenFixture);
        expect(await profile.schemaURI()).to.equal(schemaURI);
    });


    /*
    * Below are the test cases for mint and burn semantic SBT.
    * Due to predicate in contract has five data types: int, string, address, subject and blankNode
    * the fist five cases are belonging to the respective data type
    * the last one is for the unions of five data types
    */
    describe("Create profile", function () {
        it("Create a profile", async function () {
            const {profile, owner} = await loadFixture(deployTokenFixture);
            await profile.createProfile([owner.address,"name","avatar","nostr"]);

            expect(await profile.rdfOf(1)).equal(":Profile_1 p:name \"name\";p:avatar \"avatar\";p:nostr \"nostr\";p:owner :Soul_0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266;p:connectionAddress :Soul_0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266.");
        });

        it("Create two profile", async function () {
            const {profile, owner,addr1} = await loadFixture(deployTokenFixture);
            await profile.createProfile([owner.address,"name","avatar","nostr"]);
            await profile.createProfile([addr1.address,"name","avatar","nostr"]);

            expect(await profile.rdfOf(1)).equal(":Profile_1 p:name \"name\";p:avatar \"avatar\";p:nostr \"nostr\";p:owner :Soul_0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266;p:connectionAddress :Soul_0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266.");
            expect(await profile.rdfOf(2)).equal(":Profile_2 p:name \"name\";p:avatar \"avatar\";p:nostr \"nostr\";p:owner :Soul_0x70997970c51812dc3a010c7d01b50e0d17dc79c8;p:connectionAddress :Soul_0x70997970c51812dc3a010c7d01b50e0d17dc79c8.");
        });


    })

})

