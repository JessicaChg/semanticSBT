/*
* These cases are for testing the methods of Semantic SBT demo contract
*/
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const {expect} = require("chai");
const hre = require("hardhat");

const name = 'Name Service';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://Za2Zvs8bYMKqqS0dfvA1M5g_qkQzyM1nkKG32RWv_9Q';
const class_ = ["Domain"];
const predicate_ = [["hold", 3], ["resolved", 3]];


/*
* Before Mint SBT, should initial the parameters of this contract. In this step, we prepare the element of semantic SBT
* @param name The name for the Semantic SBT
* @param symbol The symbol for the Semantic SBT
* @param baseURI The URI may point to a JSON file that conforms to the "ERC721Metadata JSON Schema".
* @param schemaURI The URI of the contract witch point to a JSON file that conforms to the "ISemanticMetadata Metadata JSON Schema".
* @param [className] The array of class name which are used for define the "SUBJECT" of SPO 
* @param [className] The array of five data types of predicates which are used for define the "PREDICATE" of SPO 
*/
describe("Name Service contract", function () {
    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogic");
        const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
        console.log(
            `SemanticSBTLogic deployed ,contract address: ${semanticSBTLogicLibrary.address}`
        );

        const contractName = "NameService";
        const MyContract = await hre.ethers.getContractFactory(contractName, {
            libraries: {
                SemanticSBTLogic: semanticSBTLogicLibrary.address,
            }
        });
        const nameService = await MyContract.deploy();

        await nameService.initialize(
            owner.address,
            name,
            symbol,
            baseURI,
            schemaURI,
            class_,
            predicate_);
        return {nameService, owner, addr1, addr2};
    }

    // check semanticSBT belong this contract owner
    it("owner", async function () {
        const {nameService, owner} = await loadFixture(deployTokenFixture);
        expect(await nameService.owner()).to.equal(owner.address);
    });
    // make sure contract owner can mint SBT
    it("minter", async function () {
        const {nameService, owner} = await loadFixture(deployTokenFixture);
        expect(await nameService.minters(owner.address)).to.equal(true);
    });

    // make sure the name of semantic SBT setup up as expected
    it("name", async function () {
        const {nameService} = await loadFixture(deployTokenFixture);
        expect(await nameService.name()).to.equal(name);
    });

    // make sure the symbol of semantic SBT setup up as expected
    it("symbol", async function () {
        const {nameService} = await loadFixture(deployTokenFixture);
        expect(await nameService.symbol()).to.equal(symbol);
    });

    // make sure the schemaURI of semantic SBT setup up as expected
    it("schemaURI", async function () {
        const {nameService} = await loadFixture(deployTokenFixture);
        expect(await nameService.schemaURI()).to.equal(schemaURI);
    });


    describe("Create domain by Name Service ", function () {
        it("Register a domain", async function () {
            const {nameService, owner} = await loadFixture(deployTokenFixture);
            const domain = "my-fist-domain";
            await nameService.register(owner.address, domain, true);

            const rdf = `:Soul_${owner.address.toLowerCase()} p:hold :Domain_${domain};p:resolved :Domain_${domain}.`;
            expect(await nameService.rdfOf(1)).to.be.equal(rdf);
        });


        it("User should fail to register a domain when the length of domain less than minDomainLength", async function () {
            const {nameService, owner,addr1} = await loadFixture(deployTokenFixture);
            const domain = "do";
            await  expect(nameService.connect(addr1).register(owner.address, domain, true)).to.be.revertedWith("NameService: invalid length of name");
        });

        it("Register a domain,and then call the function setNameForAddr ", async function () {
            const {nameService, owner,addr1} = await loadFixture(deployTokenFixture);
            const domain = "my-domain";
            await nameService.register(owner.address,domain,false);
            expect(await  nameService.addr(domain)).to.be.equal("0x0000000000000000000000000000000000000000");
            expect(await  nameService.nameOf(owner.address)).to.be.equal("");

            await nameService.setNameForAddr(owner.address,domain);
            expect(await  nameService.addr(domain)).to.be.equal(owner.address);
            expect(await  nameService.nameOf(owner.address)).to.be.equal(domain);
        });

    })

})

