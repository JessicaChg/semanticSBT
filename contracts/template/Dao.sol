// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../core/SemanticSBT.sol";
import "../interfaces/social/IDao.sol";

contract Dao is IDao, SemanticSBT {

    using Strings for uint256;
    using Strings for address;

    SubjectPO[] private joinDaoSubjectPO;

    uint256 constant JOIN_PREDICATE_INDEX = 1;

    uint256 constant SOUL_CLASS_INDEX = 1;
    uint256 constant DAO_CLASS_INDEX = 2;

    address public daoOwner;
    string public _daoURI;
    bool _isFreeJoin;
    mapping(address => uint256) ownedTokenId;


    modifier onlyDaoOwner{
        require(msg.sender == daoOwner, "Dao: must be daoOwner");
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
    }

    function setDaoURI(string memory daoURI_) external onlyDaoOwner {
        _daoURI = daoURI_;
    }

    function setFreeJoin(bool isFreeJoin_) external onlyDaoOwner {
        _isFreeJoin = isFreeJoin_;
    }


    function ownerTransfer(address to) external onlyDaoOwner {
        daoOwner = to;
    }

    function addMember(address[] memory addr) external onlyDaoOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _join(addr[i]);
        }
    }

    function join() external returns (uint256 tokenId){
        require(_isFreeJoin, "Dao: permission denied");
        tokenId = _join(msg.sender);
    }

    function remove(address addr) external returns (uint256 tokenId){
        require(msg.sender == daoOwner || msg.sender == addr, "Dao: permission denied");
        tokenId = ownedTokenId[addr];
        require(ownedTokenId[addr] != 0, "Dao: not the member of dao");
        super._burn(addr, ownedTokenId[addr]);
        delete ownedTokenId[addr];
    }

    function daoURI() external view returns (string memory){
        return _daoURI;
    }

    function ownerOfDao() external view returns (address){
        return daoOwner;
    }

    function isFreeJoin() external view returns (bool){
        return _isFreeJoin;
    }

    function isMember(address addr) external view returns (bool){
        return ownedTokenId[addr] != 0;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IDao).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    function _setOwner(address owner) internal {
        daoOwner = owner;
        uint256 sIndex = _addSubject(address(this).toHexString(), DAO_CLASS_INDEX);
        joinDaoSubjectPO.push(SubjectPO(JOIN_PREDICATE_INDEX, sIndex));
    }

    function _join(address addr) internal returns (uint256 tokenId){
        require(ownedTokenId[addr] == 0, string.concat("Dao:", addr.toHexString(), " already minted"));
        tokenId = _addEmptyToken(addr, 0);
        ownedTokenId[addr] = tokenId;
        _mint(tokenId, addr, new IntPO[](0), new StringPO[](0), new AddressPO[](0),
            joinDaoSubjectPO, new BlankNodePO[](0));
    }


}