// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../interfaces/social/IContent.sol";

import "../core/SemanticSBT.sol";
import "../core/SemanticBaseStruct.sol";

contract Content is IContent, SemanticSBT {

    uint256 constant  PUBLIC_CONTENT_PREDICATE = 1;

    mapping(address => uint256) internal _prepareToken;
    mapping(address => mapping(string => uint256)) internal _mintContent;
    mapping(uint256 => string) _contentOf;

    /* ============ External Functions ============ */

    function ownedPrepareToken(address owner) external view returns (uint256) {
        return _prepareToken[owner];
    }


    function post(uint256 tokenId, string memory content) external returns (uint256) {
        _checkPredicate(PUBLIC_CONTENT_PREDICATE, FieldType.STRING);
        require(tokenId > 0, "Content:Token id not exist");
        require(_prepareToken[msg.sender] == tokenId, "Content:Permission denied");
        _mint(tokenId, PUBLIC_CONTENT_PREDICATE, content);
        delete _prepareToken[msg.sender];
        _mintContent[msg.sender][content] = tokenId;
        _contentOf[tokenId] = content;
        return tokenId;
    }


    function prepareToken() external returns (uint256) {
        require(_prepareToken[msg.sender] == 0, "Content:Already prepared");
        uint256 tokenId = _addEmptyToken(msg.sender, 0);
        _prepareToken[msg.sender] = tokenId;
        return tokenId;
    }

    function contentOf(uint256 tokenId) external view returns (string memory){
        return _contentOf[tokenId];
    }



    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IContent).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    /* ============ Internal Functions ============ */

    function _mint(uint256 tokenId, uint256 pIndex, string memory object) internal {
        StringPO[] memory stringPOList = new StringPO[](1);
        stringPOList[0] = StringPO(pIndex, object);
        _mint(
            tokenId,
            msg.sender,
            new IntPO[](0),
            stringPOList,
            new AddressPO[](0),
            new SubjectPO[](0),
            new BlankNodePO[](0)
        );
    }
}
