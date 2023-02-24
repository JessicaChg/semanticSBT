// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../interfaces/ISemanticSBTPrivacy.sol";

import "./SemanticSBT.sol";
import "./SemanticBaseStruct.sol";

abstract contract SemanticSBTPrivacy is ISemanticSBTPrivacy, SemanticSBT {


    mapping(address => mapping(uint256 => bool)) internal _isViewerOf;
    mapping(address => uint256) internal _prepareToken;
    mapping(address => mapping(string => uint256)) internal _mintObject;
    string internal constant PRIVACY_PREFIX = "[Privacy]";


    /* ============ External Functions ============ */

    function isViewerOf(address viewer, uint256 tokenId) external view returns (bool) {
        return isOwnerOf(viewer, tokenId) || _isViewerOf[viewer][tokenId];
    }

    function ownedPrepareToken(address owner) external view returns (uint256) {
        return _prepareToken[owner];
    }

    function mintedObject(address owner, string memory object) external view returns (uint256) {
        return _mintObject[owner][object];
    }

    function addViewer(address[] memory viewer, uint256 tokenId) external {
        require(isOwnerOf(msg.sender, tokenId), "SemanticSBTPrivacy:Permission denied");
        for (uint256 i = 0; i < viewer.length; i++) {
            if (!_isViewerOf[viewer[i]][tokenId]) {
                _isViewerOf[viewer[i]][tokenId] = true;
            }
        }
    }

    function prepareToken() external returns (uint256) {
        require(_prepareToken[msg.sender] == 0, "SemanticSBTPrivacy:Already prepared");
        uint256 tokenId = _addEmptyToken(msg.sender, 0);
        _prepareToken[msg.sender] = tokenId;
        return tokenId;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(ISemanticSBTPrivacy).interfaceId ||
        super.supportsInterface(interfaceId);
    }
}
