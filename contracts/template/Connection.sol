// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../core/SemanticSBT.sol";
import "../interfaces/social/IConnection.sol";

contract Connection is IConnection, SemanticSBT {

    using Strings for uint256;
    using Strings for address;

    SubjectPO[] private ownerSubjectPO;

    uint256 constant followingPredicateIndex = 1;

    uint256 constant soulCIndex = 1;

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
    ) external  {
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


    function follow() external returns (uint256) {
        require(getMinted() == 0 || super.tokenOfOwnerByIndex(msg.sender, 0) == 0, "Follow:Already followed!");
        uint256 sIndex = _addSubject(msg.sender.toHexString(), soulCIndex);
        uint256 tokenId = _addEmptyToken(msg.sender, sIndex);
        _mint(tokenId, msg.sender, new IntPO[](0), new StringPO[](0), new AddressPO[](0), ownerSubjectPO, new BlankNodePO[](0));

    }

    function mint(address to) external returns (uint256) {
        require(getMinted() == 0 || super.tokenOfOwnerByIndex(to, 0) == 0, "Connection:Already follow");
        uint256 sIndex = _addSubject(to.toHexString(), soulCIndex);
        uint256 tokenId = _addEmptyToken(to, sIndex);
        _mint(tokenId, to, new IntPO[](0), new StringPO[](0), new AddressPO[](0), ownerSubjectPO, new BlankNodePO[](0));

    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IConnection).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    function _setOwner(address owner) internal {
        uint256 sIndex = _addSubject(owner.toHexString(), soulCIndex);
        ownerSubjectPO.push(SubjectPO(followingPredicateIndex, sIndex));
    }


}