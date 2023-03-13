// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../core/SemanticSBT.sol";
import "../interfaces/social/IFollow.sol";

contract Follow is IFollow, SemanticSBT, ReentrancyGuard {

    using Strings for uint256;
    using Strings for address;

    SubjectPO[] private ownerSubjectPO;

    uint256 constant FOLLOWING_PREDICATE_INDEX = 1;

    uint256 constant SOUL_CLASS_INDEX = 1;

    mapping(address => bool) _isFollowing;

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
    ) external override {
        super.initialize(minter, name_, symbol_, baseURI_, schemaURI_, classes_, predicates_);
        _setOwner(owner);
    }


    function follow() external {
        require(!_isFollowing[msg.sender], "Follow:Already followed!");
        _isFollowing[msg.sender] = true;
        uint256 sIndex = _addSubject(msg.sender.toHexString(), SOUL_CLASS_INDEX);
        uint256 tokenId = _addEmptyToken(msg.sender, sIndex);
        _mint(tokenId, msg.sender, new IntPO[](0), new StringPO[](0), new AddressPO[](0), ownerSubjectPO, new BlankNodePO[](0));
    }

    function unfollow() external {
        uint256 tokenId = tokenOfOwnerByIndex(msg.sender, 0);
        super._burn(msg.sender, tokenId);
        _isFollowing[msg.sender] = false;
    }

    function isFollowing(address addr) external view returns (bool){
        return _isFollowing[addr];
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IFollow).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    function _setOwner(address owner) internal {
        uint256 sIndex = _addSubject(owner.toHexString(), SOUL_CLASS_INDEX);
        ownerSubjectPO.push(SubjectPO(FOLLOWING_PREDICATE_INDEX, sIndex));
    }


}