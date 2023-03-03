/*
* These cases are for testing the methods of Semantic SBT demo contract
*/
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const {expect} = require("chai");
const hre = require("hardhat");
const keccak256 = require("keccak256");
const {MerkleTree} = require("merkletreejs");

const name = 'Public Content';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://eV_a_cVZdbVcTEWzJjscg4cloGFnNyFu8tZuBBY0YaM';
const class_ = [];
const predicate_ = [["publicContent", 1]];
const content =  "ar://the tx hash of content on arweave";

/*
* Before Mint SBT, should initial the parameters of this contract. In this step, we prepare the element of semantic SBT
* @param name The name for the Semantic SBT
* @param symbol The symbol for the Semantic SBT
* @param baseURI The URI may point to a JSON file that conforms to the "ERC721Metadata JSON Schema".
* @param schemaURI The URI of the contract witch point to a JSON file that conforms to the "ISemanticMetadata Metadata JSON Schema".
* @param [className] The array of class name which are used for define the "SUBJECT" of SPO 
* @param [className] The array of five data types of predicates which are used for define the "PREDICATE" of SPO 
*/
describe("Public Content contract", function () {
    async function deployTokenFixture() {
        const [owner, addr1, addr2, addr3, addr4, addr5, addr6] = await ethers.getSigners();

        const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogic");
        const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();

        const contractName = "PublicContent";
        const MyContract = await hre.ethers.getContractFactory(contractName, {
            libraries: {
                SemanticSBTLogic: semanticSBTLogicLibrary.address,
            }
        });
        const publicContent = await MyContract.deploy();

        await publicContent.initialize(
            owner.address,
            name,
            symbol,
            baseURI,
            schemaURI,
            class_,
            predicate_);
        return {publicContent: publicContent, owner, addr1};
    }

    // check semanticSBT belong this contract owner
    it("owner", async function () {
        const {publicContent, owner} = await loadFixture(deployTokenFixture);
        expect(await publicContent.owner()).to.equal(owner.address);
    });
    // make sure contract owner can mint SBT
    it("minter", async function () {
        const {publicContent, owner} = await loadFixture(deployTokenFixture);
        expect(await publicContent.minters(owner.address)).to.equal(true);
    });

    // make sure the name of semantic SBT setup up as expected
    it("name", async function () {
        const {publicContent} = await loadFixture(deployTokenFixture);
        expect(await publicContent.name()).to.equal(name);
    });

    // make sure the symbol of semantic SBT setup up as expected
    it("symbol", async function () {
        const {publicContent} = await loadFixture(deployTokenFixture);
        expect(await publicContent.symbol()).to.equal(symbol);
    });

    // make sure the schemaURI of semantic SBT setup up as expected
    it("schemaURI", async function () {
        const {publicContent} = await loadFixture(deployTokenFixture);
        expect(await publicContent.schemaURI()).to.equal(schemaURI);
    });


    /*
    * Below are the test cases for mint and burn semantic SBT.
    * Due to predicate in contract has five data types: int, string, address, subject and blankNode
    * the fist five cases are belonging to the respective data type
    * the last one is for the unions of five data types
    */
    describe("Post public content", function () {
        it("User should fail to post without call prepare token", async function () {
            const {publicContent, owner} = await loadFixture(deployTokenFixture);
            expect(await publicContent.ownedPrepareToken(owner.address)).to.equal(0);
            await expect(publicContent.post(1, "ar://the tx hash"))
                .to.revertedWith("PublicContent:Permission denied")
        });

        it("User should owner a sbt after post a public content ", async function () {
            const {publicContent, owner} = await loadFixture(deployTokenFixture);
            const subject = ':Soul_' + owner.address.toLowerCase();
            const predicate = "p:publicContent";
            const object = `"${content}"`;
            const rdf = subject + ' ' + predicate + ' ' + object + '.';

            await publicContent.prepareToken();
            expect(await publicContent.ownedPrepareToken(owner.address)).to.equal(1);

            await expect(publicContent.post(1, content))
                .to.emit(publicContent, "CreateRDF")
                .withArgs(1, rdf);
            expect(await publicContent.rdfOf(1)).to.equal(rdf);
            expect(await publicContent.contentOf(1)).to.equal(content);
        });

    })

})

