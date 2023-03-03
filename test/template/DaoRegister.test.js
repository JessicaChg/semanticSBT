/*
* These cases are for testing the methods of Semantic SBT demo contract
*/
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const {expect} = require("chai");
const hre = require("hardhat");
const keccak256 = require("keccak256");
const {MerkleTree} = require("merkletreejs");

const name = 'Dao Register';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://MaXW2Db8G5EY2LNIR_JoiTqkIB9GUxWvAtN0vzYKl5w';
const class_ = ["Dao"];
const predicate_ = [["daoContract", 3]];

const whiteListURL = "ar://";


/*
* Before Mint SBT, should initial the parameters of this contract. In this step, we prepare the element of semantic SBT
* @param name The name for the Semantic SBT
* @param symbol The symbol for the Semantic SBT
* @param baseURI The URI may point to a JSON file that conforms to the "ERC721Metadata JSON Schema".
* @param schemaURI The URI of the contract witch point to a JSON file that conforms to the "ISemanticMetadata Metadata JSON Schema".
* @param [className] The array of class name which are used for define the "SUBJECT" of SPO 
* @param [className] The array of five data types of predicates which are used for define the "PREDICATE" of SPO 
*/
describe("DaoRegister contract", function () {
    async function deployTokenFixture() {
        const [owner, addr1, addr2, addr3, addr4, addr5, addr6] = await ethers.getSigners();

        const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogic");
        const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();

        const DeployDao = await hre.ethers.getContractFactory("DeployDao", {
            libraries: {
                SemanticSBTLogic: semanticSBTLogicLibrary.address,
            }
        });
        const deployDaoLibrary = await DeployDao.deploy();


        const InitializeDao = await hre.ethers.getContractFactory("InitializeDao");
        const initializeDaoLibrary = await InitializeDao.deploy();

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
        return {daoRegister, owner, addr1, addr2, addr3, addr4, addr5, addr6};
    }

    // check semanticSBT belong this contract owner
    it("owner", async function () {
        const {daoRegister, owner} = await loadFixture(deployTokenFixture);
        expect(await daoRegister.owner()).to.equal(owner.address);
    });
    // make sure contract owner can mint SBT
    it("minter", async function () {
        const {daoRegister, owner} = await loadFixture(deployTokenFixture);
        expect(await daoRegister.minters(owner.address)).to.equal(true);
    });

    // make sure the name of semantic SBT setup up as expected
    it("name", async function () {
        const {daoRegister} = await loadFixture(deployTokenFixture);
        expect(await daoRegister.name()).to.equal(name);
    });

    // make sure the symbol of semantic SBT setup up as expected
    it("symbol", async function () {
        const {daoRegister} = await loadFixture(deployTokenFixture);
        expect(await daoRegister.symbol()).to.equal(symbol);
    });

    // make sure the schemaURI of semantic SBT setup up as expected
    it("schemaURI", async function () {
        const {daoRegister} = await loadFixture(deployTokenFixture);
        expect(await daoRegister.schemaURI()).to.equal(schemaURI);
    });


    /*
    * Below are the test cases for mint and burn semantic SBT.
    * Due to predicate in contract has five data types: int, string, address, subject and blankNode
    * the fist five cases are belonging to the respective data type
    * the last one is for the unions of five data types
    */
    describe("Deploy dao contracts ", function () {
        it("Deploy one dao contract ", async function () {
            const {daoRegister, owner} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(owner.address);

            const daoContract = await daoRegister.ownedDaoContract(owner.address);
            const rdf = `:Soul_${owner.address.toLowerCase()} p:daoContract :Dao_${daoContract[0].toLowerCase()}.`;
            expect(await daoRegister.rdfOf(1)).equal(rdf);
        });

        it("Deploy two dao contracts for two users", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(owner.address);
            await daoRegister.deployDaoContract(addr1.address);
            expect((await daoRegister.daoOf(1)).daoOwner).to.be.equal(owner.address);
            expect((await daoRegister.daoOf(2)).daoOwner).to.be.equal(addr1.address);


            const daoContract1 = await daoRegister.ownedDaoContract(owner.address);
            const rdf1 = `:Soul_${owner.address.toLowerCase()} p:daoContract :Dao_${daoContract1[0].toLowerCase()}.`;
            expect(await daoRegister.rdfOf(1)).equal(rdf1);
            const daoContract2 = await daoRegister.ownedDaoContract(addr1.address);
            const rdf2 = `:Soul_${addr1.address.toLowerCase()} p:daoContract :Dao_${daoContract2[0].toLowerCase()}.`;
            expect(await daoRegister.rdfOf(2)).equal(rdf2);
        });


        it("User should failed to join the dao without a correct proof", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(owner.address);
            await daoRegister.deployDaoContract(addr1.address);

            const daoContractAddress = await daoRegister.ownedDaoContract(addr1.address);
            const daoContract = await hre.ethers.getContractAt("Dao", daoContractAddress[0]);
            await expect(daoContract.connect(owner).join([])).to.be.revertedWith("Dao: permission denied");
        });


        it("User should join the dao when use correct proof", async function () {
            const {
                daoRegister,
                owner,
                addr1,
                addr2,
                addr3,
                addr4,
                addr5,
                addr6
            } = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address);

            const daoContractAddress = await daoRegister.ownedDaoContract(addr1.address);
            const daoContract = await hre.ethers.getContractAt("Dao", daoContractAddress[0]);
            let whitelistAddresses = [
                owner.address,
                addr2.address,
                addr3.address,
                addr4.address,
                addr5.address,
            ];
            let leafNodes = whitelistAddresses.map(address => keccak256(address));
            let tree = new MerkleTree(leafNodes, keccak256, {sortPairs: true});
            await expect(daoContract.connect(addr1).invite(whiteListURL, tree.getHexRoot()));
            expect(await daoContract.whiteListURL()).to.equal(whiteListURL);
            expect(await daoContract.root()).to.equal(tree.getHexRoot());

            let leaf = keccak256(addr2.address);
            let proof = tree.getHexProof(leaf);
            const rdf = ":Soul_" + addr2.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(addr2).join(proof))
                .to.emit(daoContract, "CreateRDF")
                .withArgs(1, rdf);
            await expect(daoContract.connect(addr6).join([])).to.be.revertedWith("Dao: permission denied");
        });

        it("User should join the dao when free join", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address);

            const daoContractAddress = await daoRegister.ownedDaoContract(addr1.address);
            const daoContract = await hre.ethers.getContractAt("Dao", daoContractAddress[0]);
            await daoContract.connect(addr1).setFreeJoin(true);
            const rdf = ":Soul_" + owner.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).join([]))
                .to.emit(daoContract, "CreateRDF")
                .withArgs(1, rdf);
            expect(await daoContract.rdfOf(1)).equal(rdf);
            expect(await daoContract.isMember(owner.address)).equal(true);
        });

        it("User should burn the sbt when quit from dao", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address);

            const daoContractAddress = await daoRegister.ownedDaoContract(addr1.address);
            const daoContract = await hre.ethers.getContractAt("Dao", daoContractAddress[0]);
            await daoContract.connect(addr1).setFreeJoin(true);
            const rdf = ":Soul_" + owner.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).join([]))
                .to.emit(daoContract, "CreateRDF")
                .withArgs(1, rdf);
            await expect(daoContract.connect(owner).quit(owner.address))
                .to.emit(daoContract, "RemoveRDF")
                .withArgs(1, rdf);
            expect(await daoContract.isMember(owner.address)).equal(false);
        });

        it("User should burn the sbt when the owner of dao remove user from dao", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address);

            const daoContractAddress = await daoRegister.ownedDaoContract(addr1.address);
            const daoContract = await hre.ethers.getContractAt("Dao", daoContractAddress[0]);
            await daoContract.connect(addr1).setFreeJoin(true);
            const rdf = ":Soul_" + owner.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).join([]))
                .to.emit(daoContract, "CreateRDF")
                .withArgs(1, rdf);
            await expect(daoContract.connect(addr1).quit(owner.address))
                .to.emit(daoContract, "RemoveRDF")
                .withArgs(1, rdf);
            expect(await daoContract.isMember(owner.address)).equal(false);
        });
    })

})

