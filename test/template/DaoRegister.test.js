/*
* These cases are for testing the methods of Semantic SBT demo contract
*/
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const {expect} = require("chai");
const hre = require("hardhat");
const Bytes = require("@ethersproject/bytes");

const name = 'DAO Register';
const symbol = 'SBT';
const baseURI = 'https://api.example.com/v1/';
const schemaURI = 'ar://7mRfawDArdDEcoHpiFkmrURYlMSkREwDnK3wYzZ7-x4';
const class_ = ["Contract"];
const predicate_ = [["daoContract", 3]];

const firstDAOName = 'First DAO';
const secondDAOName = 'Second DAO';


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

        const SemanticSBTLogic = await hre.ethers.getContractFactory("SemanticSBTLogicUpgradeable");
        const semanticSBTLogicLibrary = await SemanticSBTLogic.deploy();

        const DaoRegisterLogic = await hre.ethers.getContractFactory("DaoRegisterLogic");
        const daoRegisterLogicLibrary = await DaoRegisterLogic.deploy();
        const DaoLogic = await hre.ethers.getContractFactory("DaoLogic", {
            libraries: {
                SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
            }
        });
        const daoLogicLibrary = await DaoLogic.deploy();
        const Dao = await hre.ethers.getContractFactory("Dao", {
            libraries: {
                SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
                DaoLogic: daoLogicLibrary.address,
            }
        });
        const dao = await Dao.deploy();
        await dao.deployTransaction.wait();

        const contractName = "DaoRegister";
        const MyContract = await hre.ethers.getContractFactory(contractName, {
            libraries: {
                SemanticSBTLogicUpgradeable: semanticSBTLogicLibrary.address,
                DaoRegisterLogic: daoRegisterLogicLibrary.address,
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
        await daoRegister.setDaoImpl(dao.address);
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
    describe("Deploy DAO contracts ", function () {
        it("Deploy one DAO contract ", async function () {
            const {daoRegister, owner} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(owner.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(owner.address, 0);
            const {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const rdf = `:Soul_${owner.address.toLowerCase()} p:daoContract :Contract_${contractAddress.toLowerCase()}.`;
            expect(await daoRegister.rdfOf(1)).equal(rdf);

            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            expect(await daoContract.name()).equal(firstDAOName)
            const rdfInDao = `:Soul_${owner.address.toLowerCase()} p:join :Dao_${contractAddress.toLowerCase()}.`;
            expect(await daoContract.rdfOf(1)).equal(rdfInDao);
        });

        it("Deploy two DAO contracts for two users", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(owner.address, firstDAOName);
            await daoRegister.deployDaoContract(addr1.address, secondDAOName);
            expect((await daoRegister.daoOf(1)).daoOwner).to.be.equal(owner.address);
            expect((await daoRegister.daoOf(2)).daoOwner).to.be.equal(addr1.address);


            const tokenId1 = await daoRegister.tokenOfOwnerByIndex(owner.address, 0);
            const tokenId2 = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            var {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId1);
            const rdf1 = `:Soul_${owner.address.toLowerCase()} p:daoContract :Contract_${contractAddress.toLowerCase()}.`;
            expect(await daoRegister.rdfOf(1)).equal(rdf1);
            const firstDaoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            expect(await firstDaoContract.name()).equal(firstDAOName)

            var {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId2);
            const rdf2 = `:Soul_${addr1.address.toLowerCase()} p:daoContract :Contract_${contractAddress.toLowerCase()}.`;
            expect(await daoRegister.rdfOf(2)).equal(rdf2);
            const secondDaoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            expect(await secondDaoContract.name()).equal(secondDAOName)
        });


        it("User should failed to join the DAO when the DAO is not free to join", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(owner.address, firstDAOName);
            await daoRegister.deployDaoContract(addr1.address, secondDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            var {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            await expect(daoContract.connect(owner).join()).to.be.revertedWith("Dao: permission denied");
        });


        it("Users should join a DAO after the owner adds them to the DAO", async function () {
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
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            var {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            let member = [
                owner.address,
                addr2.address,
                addr3.address,
                addr4.address,
                addr5.address,
            ];
            const rdf = ":Soul_" + owner.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(addr1).addMember(member))
                .to.emit(daoContract, "CreateRDF")
                .withArgs(2, rdf)

            await expect(daoContract.connect(addr6).join()).to.be.revertedWith("Dao: permission denied");
        });

        it("User should join the DAO when the DAO is free join", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            const {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            await daoContract.connect(addr1).setFreeJoin(true);
            const rdf = ":Soul_" + owner.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).join())
                .to.emit(daoContract, "CreateRDF")
                .withArgs(2, rdf);
            expect(await daoContract.rdfOf(2)).equal(rdf);
            expect(await daoContract.isMember(owner.address)).equal(true);
        });

        it("User should burn the sbt when removed from DAO", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            const {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            await daoContract.connect(addr1).setFreeJoin(true);
            const rdf = ":Soul_" + owner.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).join())
                .to.emit(daoContract, "CreateRDF")
                .withArgs(2, rdf);
            await expect(daoContract.connect(owner).remove(owner.address))
                .to.emit(daoContract, "RemoveRDF")
                .withArgs(2, rdf);
            expect(await daoContract.isMember(owner.address)).equal(false);
        });

        it("User should burn the sbt when the owner of DAO remove user from DAO", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            const {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            await daoContract.connect(addr1).setFreeJoin(true);
            const rdf = ":Soul_" + owner.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).join())
                .to.emit(daoContract, "CreateRDF")
                .withArgs(2, rdf);
            await expect(daoContract.connect(addr1).remove(owner.address))
                .to.emit(daoContract, "RemoveRDF")
                .withArgs(2, rdf);
            expect(await daoContract.isMember(owner.address)).equal(false);
        });

        it("The owner of dao could set daoURI", async function () {
            const {daoRegister, owner, addr1} = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            const {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);

            const daoURI = "test-dao-URI";
            const rdf = `:Dao_${contractAddress.toLowerCase()} p:daoURI "${daoURI}" . `
            await expect(daoContract.connect(addr1).setDaoURI(daoURI))
                .to.emit(daoContract, 'CreateRDF')
                .withArgs(0, rdf);
            await expect(daoContract.connect(addr1).setDaoURI(daoURI))
                .to.emit(daoContract, 'UpdateRDF')
                .withArgs(0, rdf);
        });
    })

    describe("Call dao with signData", function () {

        it("Add member with signData", async function () {
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
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            var {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);

            let members = [
                owner.address,
                addr2.address,
                addr3.address,
                addr4.address,
                addr5.address,
            ];

            let name = await daoContract.name();
            let nonce = await daoContract.nonces(addr1.address);
            let deadline = Date.parse(new Date()) / 1000 + 100;
            let sign = await getSign(buildAddMember(
                    name,
                    daoContract.address.toLowerCase(),
                    members,
                    parseInt(nonce),
                    deadline),
                addr1.address);
            let param = {
                "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
                "addr": addr1.address,
                "members": members
            }
            const rdf = ":Soul_" + owner.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).addMemberWithSign(param))
                .to.emit(daoContract, "CreateRDF")
                .withArgs(2, rdf)
        });


        it("Join a dao with signData", async function () {
            const {
                daoRegister,
                owner,
                addr1,
                addr2
            } = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            var {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            await daoContract.connect(addr1).setFreeJoin(true);

            let name = await daoContract.name();
            let nonce = await daoContract.nonces(addr2.address);
            let deadline = Date.parse(new Date()) / 1000 + 100;
            let sign = await getSign(buildJoinParam(
                    name,
                    daoContract.address.toLowerCase(),
                    parseInt(nonce),
                    deadline),
                addr2.address);
            let param = {
                "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
                "addr": addr2.address
            }
            const rdf = ":Soul_" + addr2.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).joinWithSign(param))
                .to.emit(daoContract, "CreateRDF")
                .withArgs(2, rdf)
        });


        it("Remove from a dao with signData", async function () {
            const {
                daoRegister,
                owner,
                addr1,
                addr2
            } = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            var {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);
            await daoContract.connect(addr1).setFreeJoin(true);

            let name = await daoContract.name();
            let nonce = await daoContract.nonces(addr2.address);
            let deadline = Date.parse(new Date()) / 1000 + 100;
            let sign = await getSign(buildJoinParam(
                    name,
                    daoContract.address.toLowerCase(),
                    parseInt(nonce),
                    deadline),
                addr2.address);
            let param = {
                "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
                "addr": addr2.address
            }
            let rdf = ":Soul_" + addr2.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).joinWithSign(param))
                .to.emit(daoContract, "CreateRDF")
                .withArgs(2, rdf)


            name = await daoContract.name();
            nonce = await daoContract.nonces(addr2.address);
            deadline = Date.parse(new Date()) / 1000 + 100;
            sign = await getSign(buildRemoveParam(
                    name,
                    daoContract.address.toLowerCase(),
                    addr2.address.toLowerCase(),
                    parseInt(nonce),
                    deadline),
                addr2.address);
            param = {
                "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
                "addr": addr2.address,
                "member": addr2.address
            }
            rdf = ":Soul_" + addr2.address.toLowerCase() + " p:join :Dao_" + daoContract.address.toLowerCase() + ".";
            await expect(daoContract.connect(owner).removeWithSign(param))
                .to.emit(daoContract, "RemoveRDF")
                .withArgs(2, rdf)
        });

        it("Set daoURI with signData", async function () {
            const {
                daoRegister,
                owner,
                addr1,
                addr2
            } = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            var {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);

            const daoURI = 'test-dao-URI';
            let name = await daoContract.name();
            let nonce = await daoContract.nonces(addr2.address);
            let deadline = Date.parse(new Date()) / 1000 + 100;
            let sign = await getSign(buildSetDaoURIParam(
                    name,
                    daoContract.address.toLowerCase(),
                    daoURI,
                    parseInt(nonce),
                    deadline),
                addr1.address);
            let param = {
                "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
                "addr": addr1.address,
                "daoURI": daoURI
            }
            await daoContract.connect(owner).setDaoURIWithSign(param);
            expect(await daoContract.daoURI()).equal(daoURI);
        });

        it("Set freeJoin signData", async function () {
            const {
                daoRegister,
                owner,
                addr1,
                addr2
            } = await loadFixture(deployTokenFixture);
            await daoRegister.deployDaoContract(addr1.address, firstDAOName);

            const tokenId = await daoRegister.tokenOfOwnerByIndex(addr1.address, 0);
            var {daoOwner, contractAddress} = await daoRegister.daoOf(tokenId);
            const daoContract = await hre.ethers.getContractAt("Dao", contractAddress);

            const isFreeJoin = true;
            let name = await daoContract.name();
            let nonce = await daoContract.nonces(addr2.address);
            let deadline = Date.parse(new Date()) / 1000 + 100;
            let sign = await getSign(buildSetFreeJoinParam(
                    name,
                    daoContract.address.toLowerCase(),
                    isFreeJoin,
                    parseInt(nonce),
                    deadline),
                addr1.address);
            let param = {
                "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
                "addr": addr1.address,
                "isFreeJoin": isFreeJoin
            }
            await daoContract.connect(owner).setFreeJoinWithSign(param);
            expect(await daoContract.isFreeJoin()).equal(true);
        });
    })

    async function getSign(msgParams, signerAddress) {
        const params = [signerAddress, msgParams];
        const trace = await hre.network.provider.send(
            "eth_signTypedData_v4", params);
        return Bytes.splitSignature(trace);
    }

    function getChainId() {
        return hre.network.config.chainId;
    }

    function buildAddMember(name, contractAddress, members, nonce, deadline) {
        return {
            domain: {
                chainId: getChainId(),
                name: name,
                verifyingContract: contractAddress,
                version: '1',
            },

            // Defining the message signing data content.
            message: {
                members: members,
                nonce: nonce,
                deadline: deadline,
            },
            // Refers to the keys of the *types* object below.
            primaryType: 'AddMemberWithSign',
            types: {
                EIP712Domain: [
                    {name: 'name', type: 'string'},
                    {name: 'version', type: 'string'},
                    {name: 'chainId', type: 'uint256'},
                    {name: 'verifyingContract', type: 'address'},
                ],
                AddMemberWithSign: [
                    {name: 'members', type: 'address[]'},
                    {name: 'nonce', type: 'uint256'},
                    {name: 'deadline', type: 'uint256'},
                ],
            },
        };
    }

    function buildJoinParam(name, contractAddress, nonce, deadline) {
        return {
            domain: {
                chainId: getChainId(),
                name: name,
                verifyingContract: contractAddress,
                version: '1',
            },

            // Defining the message signing data content.
            message: {
                nonce: nonce,
                deadline: deadline,
            },
            // Refers to the keys of the *types* object below.
            primaryType: 'JoinWithSign',
            types: {
                EIP712Domain: [
                    {name: 'name', type: 'string'},
                    {name: 'version', type: 'string'},
                    {name: 'chainId', type: 'uint256'},
                    {name: 'verifyingContract', type: 'address'},
                ],
                JoinWithSign: [
                    {name: 'nonce', type: 'uint256'},
                    {name: 'deadline', type: 'uint256'},
                ],
            },
        };
    }

    function buildRemoveParam(name, contractAddress, member, nonce, deadline) {
        return {
            domain: {
                chainId: getChainId(),
                name: name,
                verifyingContract: contractAddress,
                version: '1',
            },

            // Defining the message signing data content.
            message: {
                member: member,
                nonce: nonce,
                deadline: deadline,
            },
            // Refers to the keys of the *types* object below.
            primaryType: 'RemoveWithSign',
            types: {
                EIP712Domain: [
                    {name: 'name', type: 'string'},
                    {name: 'version', type: 'string'},
                    {name: 'chainId', type: 'uint256'},
                    {name: 'verifyingContract', type: 'address'},
                ],
                RemoveWithSign: [
                    {name: 'member', type: 'address'},
                    {name: 'nonce', type: 'uint256'},
                    {name: 'deadline', type: 'uint256'},
                ],
            },
        };
    }


    function buildSetDaoURIParam(name, contractAddress, daoURI, nonce, deadline) {
        return {
            domain: {
                chainId: getChainId(),
                name: name,
                verifyingContract: contractAddress,
                version: '1',
            },

            // Defining the message signing data content.
            message: {
                daoURI: daoURI,
                nonce: nonce,
                deadline: deadline,
            },
            // Refers to the keys of the *types* object below.
            primaryType: 'SetDaoURIWithSign',
            types: {
                EIP712Domain: [
                    {name: 'name', type: 'string'},
                    {name: 'version', type: 'string'},
                    {name: 'chainId', type: 'uint256'},
                    {name: 'verifyingContract', type: 'address'},
                ],
                SetDaoURIWithSign: [
                    {name: 'daoURI', type: 'string'},
                    {name: 'nonce', type: 'uint256'},
                    {name: 'deadline', type: 'uint256'},
                ],
            },
        };
    }

    function buildSetFreeJoinParam(name, contractAddress, isFreeJoin, nonce, deadline) {
        return {
            domain: {
                chainId: getChainId(),
                name: name,
                verifyingContract: contractAddress,
                version: '1',
            },

            // Defining the message signing data content.
            message: {
                isFreeJoin: isFreeJoin,
                nonce: nonce,
                deadline: deadline,
            },
            // Refers to the keys of the *types* object below.
            primaryType: 'SetFreeJoinWithSign',
            types: {
                EIP712Domain: [
                    {name: 'name', type: 'string'},
                    {name: 'version', type: 'string'},
                    {name: 'chainId', type: 'uint256'},
                    {name: 'verifyingContract', type: 'address'},
                ],
                SetFreeJoinWithSign: [
                    {name: 'isFreeJoin', type: 'bool'},
                    {name: 'nonce', type: 'uint256'},
                    {name: 'deadline', type: 'uint256'},
                ],
            },
        };
    }

})

