// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../core/SemanticSBTUpgradeable.sol";
import "../interfaces/social/IDao.sol";

contract Dao is IDao, SemanticSBTUpgradeable {

    using Strings for uint256;
    using Strings for address;

    struct SetDaoURIWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        string daoURI;
    }

    struct SetFreeJoinWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        bool isFreeJoin;
    }

    struct AddMemberWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        address[] members;
    }

    struct JoinWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
    }

    struct RemoveWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        address member;
    }


    SubjectPO[] private joinDaoSubjectPO;

    uint256 constant JOIN_PREDICATE_INDEX = 1;
    uint256 constant DAO_URI_PREDICATE_INDEX = 2;

    uint256 constant SOUL_CLASS_INDEX = 1;
    uint256 constant DAO_CLASS_INDEX = 2;

    string  constant DAO_CLASS_NAME = "Dao";

    address public ownerOfDao;
    string public daoURI;
    bool _setDaoURI;
    bool _isFreeJoin;
    mapping(address => uint256) ownedTokenId;

    bytes32 internal constant SET_DAO_URI_WITH_SIGN_TYPE_HASH = keccak256('SetDaoURIWithSign(string daoURI,uint256 nonce,uint256 deadline)');
    bytes32 internal constant SET_FREE_JOIN_WITH_SIGN_TYPE_HASH = keccak256('SetDaoURIWithSign(bool isFreeJoin,uint256 nonce,uint256 deadline)');
    bytes32 internal constant ADD_MEMBER_WITH_SIGN_TYPE_HASH = keccak256('AddMemberWithSign(address[] members,uint256 nonce,uint256 deadline)');
    bytes32 internal constant JOIN_WITH_SIGN_TYPE_HASH = keccak256('JoinWithSign(uint256 nonce,uint256 deadline)');
    bytes32 internal constant REMOVE_WITH_SIGN_TYPE_HASH = keccak256('RemoveWithSign(address member,uint256 nonce,uint256 deadline)');
    mapping(address => uint256) public nonces;

    modifier onlyDaoOwner{
        require(msg.sender == ownerOfDao, "Dao: must be daoOwner");
        _;
    }


    /* ============ External Functions ============ */

    function initialize(
        address owner,
        address minter,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory schemaURI_,
        string[] memory classes_,
        Predicate[] memory predicates_
    ) external override {
        super.initialize(minter, name_, symbol_, baseURI_, schemaURI_, classes_, predicates_);
        _setOwner(owner);
        _join(owner);
    }

    function setDaoURI(string memory daoURI_) external {
        _setDaoURIInternal(msg.sender, daoURI_);
    }

    function setFreeJoin(bool isFreeJoin_) external {
        _setFreeJoin(msg.sender, isFreeJoin_);
    }


    function ownerTransfer(address to) external {
        _ownerTransfer(msg.sender, to);
    }

    function addMember(address[] memory addr) external onlyDaoOwner {
        for (uint256 i = 0; i < addr.length;) {
            _join(addr[i]);
            unchecked{
                i++;
            }
        }
    }

    function join() external returns (uint256 tokenId){
        require(_isFreeJoin, "Dao: permission denied");
        tokenId = _join(msg.sender);
    }

    function remove(address addr) external returns (uint256 tokenId){
        return _remove(msg.sender, addr);
    }



    function addMemberWithSign(AddMemberWithSign calldata vars) external {
        address addr;

        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name(),
                address(this),
                keccak256(
                    abi.encode(
                        ADD_MEMBER_WITH_SIGN_TYPE_HASH,
                        keccak256(abi.encodePacked(vars.members)),
                        nonces[vars.addr]++,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        require(addr == ownerOfDao, "Dao: permission denied");

        for (uint256 i = 0; i < vars.members.length;) {
            _join(vars.members[i]);
            unchecked{
                i++;
            }
        }
    }

    function joinWithSign(JoinWithSign calldata vars) external returns (uint256 tokenId){
        require(_isFreeJoin, "Dao: permission denied");
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name(),
                address(this),
                keccak256(
                    abi.encode(
                        JOIN_WITH_SIGN_TYPE_HASH,
                        nonces[vars.addr]++,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        tokenId = _join(addr);
    }

    function removeWithSign(RemoveWithSign calldata vars) external returns (uint256 tokenId){
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name(),
                address(this),
                keccak256(
                    abi.encode(
                        REMOVE_WITH_SIGN_TYPE_HASH,
                        vars.member,
                        nonces[vars.addr]++,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        return _remove(vars.member, addr);
    }


    function isFreeJoin() external view returns (bool){
        return _isFreeJoin;
    }

    function isMember(address addr) external view returns (bool){
        return ownedTokenId[addr] != 0;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBTUpgradeable) returns (bool) {
        return interfaceId == type(IDao).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    function _setOwner(address owner) internal {
        ownerOfDao = owner;
        uint256 sIndex = SemanticSBTLogicUpgradeable.addSubject(address(this).toHexString(), DAO_CLASS_NAME, _subjects, _subjectIndex, _classIndex);
        joinDaoSubjectPO.push(SubjectPO(JOIN_PREDICATE_INDEX, sIndex));
    }

    function _setDaoURIInternal(address addr, string memory daoURI_) internal {
        require(addr == ownerOfDao, "Dao: must be daoOwner");
        daoURI = daoURI_;
        string memory rdf = SemanticSBTLogicUpgradeable.buildStringRDFCustom(DAO_CLASS_NAME, address(this).toHexString(), _predicates[DAO_URI_PREDICATE_INDEX].name, string.concat('"', daoURI_, '"'));
        if (!_setDaoURI) {
            _setDaoURI = true;
            emit CreateRDF(0, rdf);
        } else {
            emit UpdateRDF(0, rdf);
        }
    }

    function _setFreeJoin(address addr, bool isFreeJoin_) internal {
        require(addr == ownerOfDao, "Dao: must be daoOwner");
        _isFreeJoin = isFreeJoin_;
    }

    function _ownerTransfer(address addr, address to) internal {
        require(addr == ownerOfDao, "Dao: must be daoOwner");
        ownerOfDao = to;
    }

    function _join(address addr) internal returns (uint256 tokenId){
        require(ownedTokenId[addr] == 0, string.concat("Dao:", addr.toHexString(), " already minted"));
        tokenId = _addEmptyToken(addr, 0);
        ownedTokenId[addr] = tokenId;
        _mint(tokenId, addr, new IntPO[](0), new StringPO[](0), new AddressPO[](0),
            joinDaoSubjectPO, new BlankNodePO[](0));
    }

    function _remove(address caller, address addr) internal returns (uint256 tokenId){
        require(caller == ownerOfDao || caller == addr, "Dao: permission denied");
        tokenId = ownedTokenId[addr];
        require(ownedTokenId[addr] != 0, "Dao: not the member of dao");
        super._burn(addr, ownedTokenId[addr]);
        delete ownedTokenId[addr];
        return tokenId;
    }

}