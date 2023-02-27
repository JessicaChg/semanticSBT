/*
* These cases are for testing the methods of Semantic SBT demo contract
*/
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const {expect} = require("chai");
const hre = require("hardhat");

const name = 'Connection Register';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://tuVCNycNQHa0adejBcnTYqzgeUPmhOznmGcUKbUKzE8';
const class_ = ["Contract"];
const predicate_ = [["connectionContract", 3]];


/*
* Before Mint SBT, should initial the parameters of this contract. In this step, we prepare the element of semantic SBT
* @param name The name for the Semantic SBT
* @param symbol The symbol for the Semantic SBT
* @param baseURI The URI may point to a JSON file that conforms to the "ERC721Metadata JSON Schema".
* @param schemaURI The URI of the contract witch point to a JSON file that conforms to the "ISemanticMetadata Metadata JSON Schema".
* @param [className] The array of class name which are used for define the "SUBJECT" of SPO 
* @param [className] The array of five data types of predicates which are used for define the "PREDICATE" of SPO 
*/
describe("ConnectionRegister contract", function () {
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


        const contractName = "FollowRegister";
        const MyContract = await hre.ethers.getContractFactory(contractName, {
            libraries: {
                SemanticSBTLogic: semanticSBTLogicLibrary.address,
                DeployConnection: deployConnectionLibrary.address,
                InitializeConnection: initializeConnectionLibrary.address,
            }
        });
        const connectionRegister = await MyContract.deploy();

        await connectionRegister.initialize(
            owner.address,
            name,
            symbol,
            baseURI,
            schemaURI,
            class_,
            predicate_);
        return {connectionRegister, owner, addr1, addr2};
    }

    // check semanticSBT belong this contract owner
    it("owner", async function () {
        const {connectionRegister, owner} = await loadFixture(deployTokenFixture);
        expect(await connectionRegister.owner()).to.equal(owner.address);
    });
    // make sure contract owner can mint SBT
    it("minter", async function () {
        const {connectionRegister, owner} = await loadFixture(deployTokenFixture);
        expect(await connectionRegister.minters(owner.address)).to.equal(true);
    });

    // make sure the name of semantic SBT setup up as expected
    it("name", async function () {
        const {connectionRegister} = await loadFixture(deployTokenFixture);
        expect(await connectionRegister.name()).to.equal(name);
    });

    // make sure the symbol of semantic SBT setup up as expected
    it("symbol", async function () {
        const {connectionRegister} = await loadFixture(deployTokenFixture);
        expect(await connectionRegister.symbol()).to.equal(symbol);
    });

    // make sure the schemaURI of semantic SBT setup up as expected
    it("schemaURI", async function () {
        const {connectionRegister} = await loadFixture(deployTokenFixture);
        expect(await connectionRegister.schemaURI()).to.equal(schemaURI);
    });


    /*
    * Below are the test cases for mint and burn semantic SBT.
    * Due to predicate in contract has five data types: int, string, address, subject and blankNode
    * the fist five cases are belonging to the respective data type
    * the last one is for the unions of five data types
    */
    describe("Deploy connection contracts and follow other user", function () {
        it("Deploy one connection contract ", async function () {
            const {connectionRegister, owner} = await loadFixture(deployTokenFixture);
            await connectionRegister.deployConnectionContract(owner.address);

            const connectionContract = await connectionRegister.ownedConnectionContract(owner.address);
            const rdf = `:Soul_${owner.address.toLowerCase()} p:connectionContract :Contract_${connectionContract.toLowerCase()}.`;
            expect(await connectionRegister.rdfOf(1)).equal(rdf);
        });

        it("Deploy two connection contracts for two users", async function () {
            const {connectionRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await connectionRegister.deployConnectionContract(owner.address);
            await connectionRegister.deployConnectionContract(addr1.address);

            const connectionContract1 = await connectionRegister.ownedConnectionContract(owner.address);
            const rdf1 = `:Soul_${owner.address.toLowerCase()} p:connectionContract :Contract_${connectionContract1.toLowerCase()}.`;
            expect(await connectionRegister.rdfOf(1)).equal(rdf1);
            const connectionContract2 = await connectionRegister.ownedConnectionContract(addr1.address);
            const rdf2 = `:Soul_${addr1.address.toLowerCase()} p:connectionContract :Contract_${connectionContract2.toLowerCase()}.`;
            expect(await connectionRegister.rdfOf(2)).equal(rdf2);
        });

        it("User should fail to follow when the followed user doesn't have connection contract", async function () {
            const {connectionRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await connectionRegister.deployConnectionContract(owner.address);
            expect(connectionRegister.follow([addr1.address], [])).to.be.revertedWith(`${addr1.address} does not have connection contract`);
        });

        it("User should have a SBT at followed user's connection contract", async function () {
            const {connectionRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await connectionRegister.deployConnectionContract(owner.address);
            await connectionRegister.deployConnectionContract(addr1.address);
            await connectionRegister.follow([addr1.address], []);

            const connectionContractAddress = await connectionRegister.ownedConnectionContract(addr1.address);
            const connection = await hre.ethers.getContractAt("Connection", connectionContractAddress);

            const rdf = `:Soul_${owner.address.toLowerCase()} p:following :Soul_${addr1.address.toLowerCase()}.`;
            expect(await connection.rdfOf(1)).to.be.equal(rdf);
        });


    })

})

