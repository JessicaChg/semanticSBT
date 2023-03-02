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

    uint256 constant joinPredicateIndex = 1;

    uint256 constant soulCIndex = 1;
    uint256 constant daoCIndex = 1;

    address public daoOwner;
    string public daoInfo;
    bool _isFreeJoin;
    mapping(address => uint256) ownedTokenId;

    string public whiteListURL;
    bytes32 public root;

    modifier onlyDaoOwner{
        require(msg.sender == daoOwner, "Dao: must be daoOwner");
        _;
    }


    /* ============ External Functions ============ */

    function init(
        address owner,
        address minter,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory schemaURI_,
        string[] memory classes_,
        Predicate[] memory predicates_
    ) external {
        super.initialize(minter, name_, symbol_, baseURI_, schemaURI_, classes_, predicates_);
        _setOwner(owner);
    }

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

    function setDaoInfo(string memory daoInfo_) external onlyDaoOwner {
        daoInfo = daoInfo_;
    }

    function setFreeJoin(bool isFreeJoin_) external onlyDaoOwner {
        _isFreeJoin = isFreeJoin_;
    }


    function invite(string memory whiteListURL_, bytes32 root_) external onlyDaoOwner {
        whiteListURL = whiteListURL_;
        root = root_;
    }

    function join(bytes32[] calldata proof) external returns (uint256){
        require(_isFreeJoin || _verify(_leaf(msg.sender), proof), "Activity: permission denied");
        require(ownedTokenId[msg.sender] == 0, "Activity: already minted");

        uint256 tokenId = _addEmptyToken(msg.sender, 0);

        _mint(tokenId, msg.sender, new IntPO[](0), new StringPO[](0), new AddressPO[](0),
            joinDaoSubjectPO, new BlankNodePO[](0));
        ownedTokenId[msg.sender] = tokenId;
    }

    function quit(address to) external returns (uint256){
        require(msg.sender == daoOwner || msg.sender == to, "Dao: permission denied");
        require(ownedTokenId[to] != 0, "Dao: not the member of dao");
        super._burn(to, ownedTokenId[to]);
    }

    function isFreeJoin() external view returns (bool){
        return _isFreeJoin;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IDao).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    function _setOwner(address owner) internal {
        daoOwner = owner;
        uint256 sIndex = _addSubject(address(this).toHexString(), daoCIndex);
        joinDaoSubjectPO.push(SubjectPO(joinPredicateIndex, sIndex));
    }


    function _leaf(address account) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account));
    }

    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }


}