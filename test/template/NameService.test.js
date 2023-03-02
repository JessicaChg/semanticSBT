/*
* These cases are for testing the methods of Semantic SBT demo contract
*/
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const {expect} = require("chai");
const hre = require("hardhat");
const {ethers, upgrades} = require("hardhat");

const name = 'Name Service';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://Za2Zvs8bYMKqqS0dfvA1M5g_qkQzyM1nkKG32RWv_9Q';
const class_ = ["Domain"];
const predicate_ = [["hold", 3], ["resolved", 3]];

const minDomainLength_ = 3;
const domainLengthControl = {"_domainLength": 4, "_maxCount": 1};//means the maxCount of 4 characters is 1


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


        const SemanticSBTLogic = await ethers.getContractFactory("SemanticSBTLogicUpgradeable");
        const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();
        const NameServiceLogicLibrary = await ethers.getContractFactory("NameServiceLogic");
        const nameServiceLogicLibrary = await NameServiceLogicLibrary.deploy();

        const contractName = "NameService";
        console.log(contractName)

        const MyContract = await ethers.getContractFactory(contractName,{
            libraries:{
                SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
                NameServiceLogic: nameServiceLogicLibrary.address,
            }
        });
        const nameService = await upgrades.deployProxy(MyContract,
            [owner.address,
                name,
                symbol,
                baseURI,
                schemaURI,
                class_,
                predicate_],
            {unsafeAllowLinkedLibraries: true});

        await nameService.deployed();
        await (await nameService.setDomainLengthControl(minDomainLength_, domainLengthControl._domainLength, domainLengthControl._maxCount)).wait();

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

            const rdf = `:Soul_${owner.address.toLowerCase()} p:resolved :Domain_${domain}.`;
            expect(await nameService.rdfOf(1)).to.be.equal(rdf);
        });


        it("User should fail to register a domain when the length of domain less than minDomainLength", async function () {
            const {nameService, owner, addr1} = await loadFixture(deployTokenFixture);
            const domain = "do";
            await expect(nameService.connect(addr1).register(owner.address, domain, true)).to.be.revertedWith("NameService: invalid length of name");
        });

        it("User should get name by domain after register a domain,and then call the function setNameForAddr ", async function () {
            const {nameService, owner, addr1} = await loadFixture(deployTokenFixture);
            const domain = "my-domain";
            await nameService.register(owner.address, domain, false);
            expect(await nameService.addr(domain)).to.be.equal("0x0000000000000000000000000000000000000000");
            expect(await nameService.nameOf(owner.address)).to.be.equal("");

            await nameService.setNameForAddr(owner.address, domain);
            expect(await nameService.addr(domain)).to.be.equal(owner.address);
            expect(await nameService.nameOf(owner.address)).to.be.equal(domain);
        });

        it("User should get addr by domain after call the function setNameForAddr ", async function () {
            const {nameService, owner, addr1} = await loadFixture(deployTokenFixture);
            const domain = "my-domain";
            await nameService.register(owner.address, domain, false);
            expect(await nameService.addr(domain)).to.be.equal("0x0000000000000000000000000000000000000000");
            expect(await nameService.nameOf(owner.address)).to.be.equal("");

            await nameService.setNameForAddr(owner.address, domain);
            expect(await nameService.addr(domain)).to.be.equal(owner.address);
            expect(await nameService.nameOf(owner.address)).to.be.equal(domain);
        });

        it("User should fail to transfer when not be transferable", async function () {
            const {nameService, owner, addr1} = await loadFixture(deployTokenFixture);
            const domain = "my-domain";
            await nameService.register(owner.address, domain, false);
            await expect(nameService.transferFrom(owner.address, addr1.address, 1)).to.be.revertedWith("SemanticSBT: must transferable")
        });


        it("User should fail to transfer when domain has resolved", async function () {
            const {nameService, owner, addr1} = await loadFixture(deployTokenFixture);
            await nameService.setTransferable(true);

            const domain = "my-domain";
            await nameService.register(owner.address, domain, true);
            await expect(nameService.transferFrom(owner.address, addr1.address, 1)).to.be.revertedWith("NameService:can not transfer when resolved");
        });


        it("User could set resolve after own a transferred token", async function () {
            const {nameService, owner, addr1} = await loadFixture(deployTokenFixture);
            await nameService.setTransferable(true);

            const domain = "my-domain";
            const rdf1 = `:Soul_${owner.address.toLowerCase()} p:hold :Domain_${domain}.`;
            await expect(nameService.register(owner.address, domain, false))
                .to.be.emit(nameService, "CreateRDF")
                .withArgs(1, rdf1);

            const rdf2 = `:Soul_${addr1.address.toLowerCase()} p:hold :Domain_${domain}.`;
            await expect(nameService.transferFrom(owner.address, addr1.address, 1))
                .to.be.emit(nameService, "UpdateRDF")
                .withArgs(1, rdf2);
        });


        it("User should fail to setProfileHash when domain has not resolved", async function () {
            const {nameService, owner, addr1} = await loadFixture(deployTokenFixture);
            const domain = "my-domain";
            
            await nameService.register(owner.address, domain, false);
            const profileHash = String(Math.random())
            expect(nameService.setProfileHash(profileHash)).to.be.revertedWith("NameService:not resolved the domain")
        })

        it("User could setProfileHash when domain has resolved and get the right profileHash", async function () {
            const {nameService, owner, addr1} = await loadFixture(deployTokenFixture);
            const domain = "my-domain";
            
            await nameService.register(owner.address, domain, true);
            const profileHash = String(Math.random())
            await nameService.setProfileHash(profileHash)
            expect(await nameService.profileHash(owner.address.toLowerCase())).to.be.equal(profileHash)
        })
    })

})

