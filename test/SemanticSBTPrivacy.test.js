/*
* These cases are for testing the methods of Semantic SBT demo contract
*/
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const {expect} = require("chai");

const name = 'privacy example SBT';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'https://schema.example.com/v1/';
const className = 'TestClass';
const intPredicate = ['intPredicate', 0];
const stringPredicate = ['stringPredicate', 1];
const addressPredicate = ['addressPredicate', 2];
const subjectPredicate = ['subjectPredicate', 3];
const blankNodePredicate = ['blankNodePredicate', 4];

/*
* Before Mint SBT, should initial the parameters of this contract. In this step, we prepare the element of semantic SBT
* @param name The name for the Semantic SBT
* @param symbol The symbol for the Semantic SBT
* @param baseURI The URI may point to a JSON file that conforms to the "ERC721Metadata JSON Schema".
* @param schemaURI The URI of the contract witch point to a JSON file that conforms to the "ISemanticMetadata Metadata JSON Schema".
* @param [className] The array of class name which are used for define the "SUBJECT" of SPO 
* @param [className] The array of five data types of predicates which are used for define the "PREDICATE" of SPO 
*/
describe("SemanticSBT contract", function () {
    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();
        console.log(owner.address);
        console.log(addr1.address);
        console.log(addr2.address);
        const SemanticSBT = await ethers.getContractFactory("SemanticSBTPrivacy");
        const semanticSBT = await SemanticSBT.deploy();
        await semanticSBT.initialize(
            owner.address,
            name,
            symbol,
            baseURI,
            schemaURI,
            [className],
            [intPredicate, stringPredicate, addressPredicate, subjectPredicate, blankNodePredicate]);
        return {semanticSBT, owner, addr1, addr2};
    }

    // check semanticSBT belong this contract owner
    it("owner", async function () {
        const {semanticSBT, owner} = await loadFixture(deployTokenFixture);
        expect(await semanticSBT.owner()).to.equal(owner.address);
    });
    // make sure contract owner can mint SBT
    it("minter", async function () {
        const {semanticSBT, owner} = await loadFixture(deployTokenFixture);
        expect(await semanticSBT.minters(owner.address)).to.equal(true);
    });

    // make sure the name of semantic SBT setup up as expected
    it("name", async function () {
        const {semanticSBT} = await loadFixture(deployTokenFixture);
        expect(await semanticSBT.name()).to.equal(name);
    });

    // make sure the symbol of semantic SBT setup up as expected
    it("symbol", async function () {
        const {semanticSBT} = await loadFixture(deployTokenFixture);
        expect(await semanticSBT.symbol()).to.equal(symbol);
    });

    // make sure the schemaURI of semantic SBT setup up as expected
    it("schemaURI", async function () {
        const {semanticSBT} = await loadFixture(deployTokenFixture);
        expect(await semanticSBT.schemaURI()).to.equal(schemaURI);
    });


    /*
    * Below are the test cases for mint and burn semantic SBT.
    * Due to predicate in contract has five data types: int, string, address, subject and blankNode
    * the fist five cases are belonging to the respective data type
    * the last one is for the unions of five data types
    */
    describe("mint and burn", function () {
        it("mint with only intPredicate,then burn", async function () {
            const {semanticSBT, owner, addr1} = await loadFixture(deployTokenFixture);
            const subject = ':Soul_' + addr1.address.toLowerCase();
            const predicate = "p:intPredicate";
            const object = 100;
            const rdf = subject + ' ' + predicate + ' ' + object + '.';
            await expect(semanticSBT.mint(addr1.address, 0, [[1, 100]], [], [], [], []))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
            expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

            await semanticSBT.connect(addr1).approve(owner.address, 1)
            await expect(semanticSBT.burn(addr1.address, 1))
                .to.emit(semanticSBT, "RemoveRDF")
                .withArgs(1, rdf);
        });

        it("mint with only stringPredicatet,then burn", async function () {
            const {semanticSBT, owner, addr1} = await loadFixture(deployTokenFixture);
            const subject = ':Soul_' + addr1.address.toLowerCase();
            const predicate = "p:stringPredicate";
            const object = '"good"';
            const rdf = subject + ' ' + predicate + ' ' + object + '.';

            await expect(semanticSBT.mint(addr1.address, 0, [], [[2, "good"]], [], [], []))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
            expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

            await semanticSBT.connect(addr1).approve(owner.address, 1)
            await expect(semanticSBT.burn(addr1.address, 1))
                .to.emit(semanticSBT, "RemoveRDF")
                .withArgs(1, rdf);
        });

        it("mint with only addressPredicate,then burn", async function () {
            const {semanticSBT, owner, addr1, addr2} = await loadFixture(deployTokenFixture);
            const subject = ':Soul_' + addr1.address.toLowerCase();
            const predicate = "p:addressPredicate";
            const object = ':Soul_' + addr2.address.toLowerCase();
            const rdf = subject + ' ' + predicate + ' ' + object + '.';

            await expect(semanticSBT.mint(addr1.address, 0, [], [], [[3, addr2.address.toLowerCase()]], [], []))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
            expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

            await semanticSBT.connect(addr1).approve(owner.address, 1)
            await expect(semanticSBT.burn(addr1.address, 1))
                .to.emit(semanticSBT, "RemoveRDF")
                .withArgs(1, rdf);
        });


        it("mint with only subjectPredicate,then burn", async function () {
            const {semanticSBT, owner, addr1} = await loadFixture(deployTokenFixture);
            const subjectValue = "myTest";
            await semanticSBT.addSubject(subjectValue, className);
            const subject = ':Soul_' + addr1.address.toLowerCase();
            const predicate = "p:subjectPredicate";
            const object = ':' + className + '_' + subjectValue;
            const rdf = subject + ' ' + predicate + ' ' + object + '.';

            await expect(semanticSBT.mint(addr1.address, 0, [], [], [], [[4, 1]], []))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
            expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

            await semanticSBT.connect(addr1).approve(owner.address, 1)
            await expect(semanticSBT.burn(addr1.address, 1))
                .to.emit(semanticSBT, "RemoveRDF")
                .withArgs(1, rdf);
        });

        it("mint with only blankNodePredicate,then burn", async function () {
            const {semanticSBT, owner, addr1} = await loadFixture(deployTokenFixture);
            const subjectValue = "myTest";
            await semanticSBT.addSubject(subjectValue, className);

            const subject = ':Soul_' + addr1.address.toLowerCase();
            const predicate = "p:blankNodePredicate";
            const object = '[p:intPredicate ' + 100 + ' ;p:subjectPredicate :' + className + '_' + subjectValue + ']';
            const rdf = subject + ' ' + predicate + ' ' + object + '.';
            await expect(semanticSBT.mint(addr1.address, 0, [], [], [], [], [[5, [[1, 100]], [], [], [[4, 1]]]]))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
            expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

            await semanticSBT.connect(addr1).approve(owner.address, 1)
            await expect(semanticSBT.burn(addr1.address, 1))
                .to.emit(semanticSBT, "RemoveRDF")
                .withArgs(1, rdf);
        });


        it("mint with all predicate,then burn", async function () {
            const {semanticSBT, owner, addr1, addr2} = await loadFixture(deployTokenFixture);
            const subjectValue = "myTest";
            await semanticSBT.addSubject(subjectValue, className);
            const rdf = ':Soul_0x70997970c51812dc3a010c7d01b50e0d17dc79c8 p:intPredicate 100;p:stringPredicate "good";' +
                'p:addressPredicate :Soul_0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc;' +
                'p:subjectPredicate :TestClass_myTest;' +
                'p:blankNodePredicate [p:intPredicate 100 ;p:subjectPredicate :TestClass_myTest].'
            await expect(semanticSBT.mint(addr1.address, 0, [[1, 100]], [[2, "good"]], [[3, addr2.address]], [[4, 1]], [[5, [[1, 100]], [], [], [[4, 1]]]]))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
            expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

            await semanticSBT.connect(addr1).approve(owner.address, 1)
            await expect(semanticSBT.burn(addr1.address, 1))
                .to.emit(semanticSBT, "RemoveRDF")
                .withArgs(1, rdf);
        });

        it("User should fail to mint privacy sbt without call prepare token", async function () {
            const {semanticSBT, owner} = await loadFixture(deployTokenFixture);
            expect(await semanticSBT.ownedPrepareToken(owner.address)).to.equal(0);
            await expect(semanticSBT.mintPrivacy(1, 2, "ar://the tx hash"))
                .to.revertedWith("SemanticSBTPrivacy:Permission denied")
        });

        it("User should prepare token before mint privacy ", async function () {
            const {semanticSBT, owner} = await loadFixture(deployTokenFixture);
            const subject = ':Soul_' + owner.address.toLowerCase();
            const predicate = "p:stringPredicate";
            const object = '"[Privacy]ar://the tx hash"';
            const rdf = subject + ' ' + predicate + ' ' + object + '.';

            await semanticSBT.prepareToken();
            expect(await semanticSBT.ownedPrepareToken(owner.address)).to.equal(1);

            await expect(semanticSBT.mintPrivacy(1, 2, "ar://the tx hash"))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
        });

        it("Should return false when user not the viewer of token", async function () {
            const {semanticSBT, owner, addr1} = await loadFixture(deployTokenFixture);
            const subject = ':Soul_' + owner.address.toLowerCase();
            const predicate = "p:stringPredicate";
            const object = '"[Privacy]ar://the tx hash"';
            const rdf = subject + ' ' + predicate + ' ' + object + '.';

            await semanticSBT.prepareToken();
            expect(await semanticSBT.ownedPrepareToken(owner.address)).to.equal(1);

            await expect(semanticSBT.mintPrivacy(1, 2, "ar://the tx hash"))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf);

            expect(await semanticSBT.isViewerOf(owner.address, 1)).to.equal(true);
            expect(await semanticSBT.isViewerOf(addr1.address, 1)).to.equal(false);
        });

        it("Should return true when user is viewer of token", async function () {
            const {semanticSBT, owner, addr1} = await loadFixture(deployTokenFixture);
            const subject = ':Soul_' + owner.address.toLowerCase();
            const predicate = "p:stringPredicate";
            const object = '"[Privacy]ar://the tx hash"';
            const rdf = subject + ' ' + predicate + ' ' + object + '.';

            await semanticSBT.prepareToken();
            expect(await semanticSBT.ownedPrepareToken(owner.address)).to.equal(1);

            await expect(semanticSBT.mintPrivacy(1, 2, "ar://the tx hash"))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf);

            expect(await semanticSBT.isViewerOf(owner.address, 1)).to.equal(true);
            expect(await semanticSBT.isViewerOf(addr1.address, 1)).to.equal(false);

            await semanticSBT.addViewer([addr1.address], 1);
            expect(await semanticSBT.isViewerOf(addr1.address, 1)).to.equal(true);
        });


        it("Mint more than one sbt with privacy ,should use different object", async function () {
            const {semanticSBT, owner, addr1} = await loadFixture(deployTokenFixture);

            for (var i = 1; i <= 10; i++) {
                const subject = ':Soul_' + owner.address.toLowerCase();
                const predicate = "p:stringPredicate";
                const object = '"[Privacy]ar://the tx hash' + i + '"';
                const rdf = subject + ' ' + predicate + ' ' + object + '.';

                await semanticSBT.prepareToken();
                expect(await semanticSBT.ownedPrepareToken(owner.address)).to.equal(i);
                await expect(semanticSBT.mintPrivacy(i, 2, "ar://the tx hash" + i))
                    .to.emit(semanticSBT, "CreateRDF")
                    .withArgs(i, rdf);
                expect(await semanticSBT.rdfOf(i)).to.equal(rdf);
            }

            expect(await semanticSBT.getMinted()).to.equal(10);
            expect(await semanticSBT.totalSupply()).to.equal(10);
        });

        it("Mint more than one sbt, both privacy sbt and non-privacy sbt", async function () {
            const {semanticSBT, owner, addr1} = await loadFixture(deployTokenFixture);
            //mint privacy sbt
            for (var i = 1; i <= 10; i++) {
                const subject = ':Soul_' + owner.address.toLowerCase();
                const predicate = "p:stringPredicate";
                const object = '"[Privacy]ar://the tx hash' + i + '"';
                const rdf = subject + ' ' + predicate + ' ' + object + '.';

                await semanticSBT.prepareToken();
                expect(await semanticSBT.ownedPrepareToken(owner.address)).to.equal(i);
                await expect(semanticSBT.mintPrivacy(i, 2, "ar://the tx hash" + i))
                    .to.emit(semanticSBT, "CreateRDF")
                    .withArgs(i, rdf);
                expect(await semanticSBT.rdfOf(i)).to.equal(rdf);
                expect(await semanticSBT.ownerOf(i)).to.equal(owner.address);
            }
            expect(await semanticSBT.getMinted()).to.equal(10);
            expect(await semanticSBT.totalSupply()).to.equal(10);

            // mint non-privacy sbt
            for (var i = 11; i <= 20; i++) {
                const subject = ':Soul_' + addr1.address.toLowerCase();
                const predicate = "p:stringPredicate";
                const object = '"hello world"';
                const rdf = subject + ' ' + predicate + ' ' + object + '.';

                await expect(semanticSBT.mint(addr1.address, 0, [], [[2, "hello world"]], [], [], []))
                    .to.emit(semanticSBT, "CreateRDF")
                    .withArgs(i, rdf);
                expect(await semanticSBT.rdfOf(i)).to.equal(rdf);
                expect(await semanticSBT.ownerOf(i)).to.equal(addr1.address);
            }
            expect(await semanticSBT.getMinted()).to.equal(20);
            expect(await semanticSBT.totalSupply()).to.equal(20);

            // mint privacy sbt
            for (var i = 21; i <= 30; i++) {
                const subject = ':Soul_' + owner.address.toLowerCase();
                const predicate = "p:stringPredicate";
                const object = '"[Privacy]ar://the tx hash' + i + '"';
                const rdf = subject + ' ' + predicate + ' ' + object + '.';

                await semanticSBT.prepareToken();
                expect(await semanticSBT.ownedPrepareToken(owner.address)).to.equal(i);
                await expect(semanticSBT.mintPrivacy(i, 2, "ar://the tx hash" + i))
                    .to.emit(semanticSBT, "CreateRDF")
                    .withArgs(i, rdf);
                expect(await semanticSBT.rdfOf(i)).to.equal(rdf);
                expect(await semanticSBT.ownerOf(i)).to.equal(owner.address);
            }
            expect(await semanticSBT.getMinted()).to.equal(30);
            expect(await semanticSBT.totalSupply()).to.equal(30);
        });


        it("Mint a sbt without privacy after call prepareToken,then mint a sbt with privacy use the prepared tokenId", async function () {
            const {semanticSBT, owner, addr1, addr2} = await loadFixture(deployTokenFixture);

            await semanticSBT.prepareToken();

            const subject = ':Soul_' + addr1.address.toLowerCase();
            const predicate = "p:stringPredicate";
            const object = '"ar://the tx hash"';
            const rdf = subject + ' ' + predicate + ' ' + object + '.';

            await expect(semanticSBT.mint(addr1.address, 0, [], [[2, "ar://the tx hash"]], [], [], []))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(2, rdf);
            expect(await semanticSBT.rdfOf(2)).to.equal(rdf);
            expect(await semanticSBT.ownerOf(2)).to.equal(addr1.address);
            expect(await semanticSBT.getMinted()).to.equal(2);
            expect(await semanticSBT.totalSupply()).to.equal(2);


            const subject1 = ':Soul_' + owner.address.toLowerCase();
            const predicate1 = "p:stringPredicate";
            const object1 = '"[Privacy]ar://the tx hash"';
            const rdf1 = subject1 + ' ' + predicate1 + ' ' + object1 + '.';
            expect(await semanticSBT.ownedPrepareToken(owner.address)).to.equal(1);

            await expect(semanticSBT.mintPrivacy(1, 2, "ar://the tx hash"))
                .to.emit(semanticSBT, "CreateRDF")
                .withArgs(1, rdf1);
            expect(await semanticSBT.rdfOf(1)).to.equal(rdf1);
            expect(await semanticSBT.ownerOf(1)).to.equal(owner.address);

            expect(await semanticSBT.getMinted()).to.equal(2);
            expect(await semanticSBT.totalSupply()).to.equal(2);
        });

    })

})

