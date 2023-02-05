// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/ISemanticSBTPrivacy.sol";

import "./SemanticSBT.sol";
import "./SemanticBaseStruct.sol";

contract SemanticSBTPrivacy is ISemanticSBTPrivacy, SemanticSBT {
    using Address for address;
    using Strings for uint256;
    using Strings for uint160;

    using Strings for address;

    mapping(address => mapping(uint256 => bool)) _isViewerOf;
    mapping(address => uint256) _prepareTokenId;
    mapping(address => mapping(string => uint256)) _mintObject;
    string constant PRIVACY_REFIX = "[Privacy]";

    function _mintPrivacy(uint256 tokenId, uint256 pIndex, string memory object) internal {
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


    /* ============ External Functions ============ */

    function isViewerOf(address viewer, uint256 tokenId) external view returns (bool) {
        return isOwnerOf(viewer, tokenId) || _isViewerOf[viewer][tokenId];
    }

    function ownedPrepareTokenId(address owner) external view returns (uint256) {
        return _prepareTokenId[owner];
    }

    function addViewer(address viewer, uint256 tokenId) external {
        require(isOwnerOf(msg.sender, tokenId), "SemanticSBTPrivacy:Permission denied");
        _isViewerOf[viewer][tokenId] = true;
    }

    function prepareTokenId() external returns (uint256) {
        require(_prepareTokenId[msg.sender] == 0, "SemanticSBTPrivacy:Already prepared");
        uint256 tokenId = _addEmptyToken(msg.sender, 0);
        _prepareTokenId[msg.sender] = tokenId;
        return tokenId;
    }

    function mintPrivacy(uint256 tokenId, uint256 pIndex, string memory object) external returns (uint256) {
        _checkPredicate(pIndex, FieldType.STRING);
        require(_prepareTokenId[msg.sender] == tokenId, "SemanticSBTPrivacy:Permission denied");
        require(_mintObject[msg.sender][object] == 0, "SemanticSBTPrivacy:Already mint");
        _mintPrivacy(tokenId, pIndex, string.concat(PRIVACY_REFIX, object));
        delete _prepareTokenId[msg.sender];
        _mintObject[msg.sender][object] = tokenId;
        return tokenId;
    }
}
