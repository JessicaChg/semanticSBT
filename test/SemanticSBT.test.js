const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");



const name = 'example SBT';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'https://schema.example.com/v1/';
const className = 'TestClass';
const intPredicate = ['intPredicate', 0];
const stringPredicate = ['stringPredicate', 1];
const addressPredicate = ['addressPredicate', 2];
const subjectPredicate = ['subjectPredicate', 3];
const blankNodePredicate = ['blankNodePredicate', 4];


describe("SemanticSBT contract", function () {
  async function deployTokenFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const SemanticSBT = await ethers.getContractFactory("SemanticSBT");
    const semanticSBT = await SemanticSBT.deploy();
    await semanticSBT.initialize(
      owner.address,
      name,
      symbol,
      baseURI,
      schemaURI,
      [className],
      [intPredicate, stringPredicate, addressPredicate, subjectPredicate, blankNodePredicate]);
    return { semanticSBT, owner, addr1, addr2 };
  }


  it("owner", async function () {
    const { semanticSBT, owner } = await loadFixture(deployTokenFixture);
    expect(await semanticSBT.owner()).to.equal(owner.address);
  });

  it("minter", async function () {
    const { semanticSBT, owner } = await loadFixture(deployTokenFixture);
    expect(await semanticSBT.minters(owner.address)).to.equal(true);
  });

  it("name", async function () {
    const { semanticSBT } = await loadFixture(deployTokenFixture);
    expect(await semanticSBT.name()).to.equal(name);
  });

  it("symbol", async function () {
    const { semanticSBT } = await loadFixture(deployTokenFixture);
    expect(await semanticSBT.symbol()).to.equal(symbol);
  });

  it("schemaURI", async function () {
    const { semanticSBT } = await loadFixture(deployTokenFixture);
    expect(await semanticSBT.schemaURI()).to.equal(schemaURI);
  });


  describe("mint and burn", function () {
    it("mint with only intPredicate,then burn", async function () {
      const { semanticSBT, owner, addr1 } = await loadFixture(deployTokenFixture);
      const subject = ':Soul_' + addr1.address.toLowerCase();
      const predicate = "p:intPredicate";
      const object = 100;
      const rdf = subject + ' ' + predicate + ' ' + object + '.';
      expect(await semanticSBT.mint(addr1.address, 0, [[1, 100]], [], [], [], []))
        .to.emit(semanticSBT, "CreateSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
      expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
      expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

      await semanticSBT.connect(addr1).approve(owner.address, 1)
      expect(await semanticSBT.burn(addr1.address, 1))
        .to.emit(semanticSBT, "RemoveSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
    });

    it("mint with only stringPredicatet,then burn", async function () {
      const { semanticSBT, owner, addr1 } = await loadFixture(deployTokenFixture);
      const subject = ':Soul_' + addr1.address.toLowerCase();
      const predicate = "p:stringPredicate";
      const object = '"good"';
      const rdf = subject + ' ' + predicate + ' ' + object + '.';

      expect(await semanticSBT.mint(addr1.address, 0, [], [[2, "good"]], [], [], []))
        .to.emit(semanticSBT, "CreateSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
      expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
      expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

      await semanticSBT.connect(addr1).approve(owner.address, 1)
      expect(await semanticSBT.burn(addr1.address, 1))
        .to.emit(semanticSBT, "RemoveSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
    });

    it("mint with only addressPredicate,then burn", async function () {
      const { semanticSBT, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
      const subject = ':Soul_' + addr1.address.toLowerCase();
      const predicate = "p:addressPredicate";
      const object = ':Soul_' + addr2.address.toLowerCase();
      const rdf = subject + ' ' + predicate + ' ' + object + '.';

      expect(await semanticSBT.mint(addr1.address, 0, [], [], [[3, addr2.address.toLowerCase()]], [], []))
        .to.emit(semanticSBT, "CreateSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
      expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
      expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

      await semanticSBT.connect(addr1).approve(owner.address, 1)
      expect(await semanticSBT.burn(addr1.address, 1))
        .to.emit(semanticSBT, "RemoveSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
    });


    it("mint with only subjectPredicate,then burn", async function () {
      const { semanticSBT, owner, addr1 } = await loadFixture(deployTokenFixture);
      const subjectValue = "myTest";
      await semanticSBT.addSubject(subjectValue, className);
      const subject = ':Soul_' + addr1.address.toLowerCase();
      const predicate = "p:subjectPredicate";
      const object = ':' + className + '_' + subjectValue;
      const rdf = subject + ' ' + predicate + ' ' + object + '.';

      expect(await semanticSBT.mint(addr1.address, 0, [], [], [], [[4, 1]], []))
        .to.emit(semanticSBT, "CreateSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
      expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
      expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

      await semanticSBT.connect(addr1).approve(owner.address, 1)
      expect(await semanticSBT.burn(addr1.address, 1))
        .to.emit(semanticSBT, "RemoveSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
    });

    it("mint with only blankNodePredicate,then burn", async function () {
      const { semanticSBT, owner, addr1 } = await loadFixture(deployTokenFixture);
      const subjectValue = "myTest";
      await semanticSBT.addSubject(subjectValue, className);

      const subject = ':Soul_' + addr1.address.toLowerCase();
      const predicate = "p:blankNodePredicate";
      const object = '[p:intPredicate ' + 100 + ' ;p:subjectPredicate :' + className + '_' + subjectValue + ']';
      const rdf = subject + ' ' + predicate + ' ' + object + '.';
      expect(await semanticSBT.mint(addr1.address, 0, [], [], [], [], [[5, [[1, 100]], [], [], [[4, 1]]]]))
        .to.emit(semanticSBT, "CreateSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
      expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
      expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

      await semanticSBT.connect(addr1).approve(owner.address, 1)
      expect(await semanticSBT.burn(addr1.address, 1))
        .to.emit(semanticSBT, "RemoveSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
    });


    it("mint with all predicate,then burn", async function () {
      const { semanticSBT, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
      const subjectValue = "myTest";
      await semanticSBT.addSubject(subjectValue, className);
      const rdf = ':Soul_0x70997970c51812dc3a010c7d01b50e0d17dc79c8 p:intPredicate 100;p:stringPredicate "good";' +
        'p:addressPredicate :Soul_0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc;' +
        'p:subjectPredicate :TestClass_myTest;' +
        'p:blankNodePredicate [p:intPredicate 100 ;p:subjectPredicate :TestClass_myTest].'
      expect(await semanticSBT.mint(addr1.address, 0, [[1, 100]], [[2, "good"]], [[3, addr2.address]], [[4, 1]], [[5, [[1, 100]], [], [], [[4, 1]]]]))
        .to.emit(semanticSBT, "CreateSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
      expect(await semanticSBT.rdfOf(1)).to.equal(rdf);
      expect(await semanticSBT.ownerOf(1)).to.equal(addr1.address);

      await semanticSBT.connect(addr1).approve(owner.address, 1)
      expect(await semanticSBT.burn(addr1.address, 1))
        .to.emit(semanticSBT, "RemoveSBT")
        .withArgs(owner.address, owner.address, 1, rdf);
    });
  })

});