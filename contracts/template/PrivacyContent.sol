// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../interfaces/social/IPrivacyContent.sol";
import "../interfaces/social/IFollowRegister.sol";
import "../interfaces/social/IFollow.sol";
import "../interfaces/social/IDaoRegister.sol";
import "../interfaces/social/IDao.sol";

import "../core/SemanticSBT.sol";
import "../core/SemanticBaseStruct.sol";

contract PrivacyContent is IPrivacyContent, SemanticSBT {

    uint256 constant  PRIVACY_DATA_PREDICATE = 1;
    string constant PRIVACY_PREFIX = "[Privacy]";

    address public followRegister;

    mapping(address => mapping(uint256 => bool)) internal _isViewerOf;
    mapping(address => uint256) internal _prepareToken;
    mapping(address => mapping(string => uint256)) internal _mintObject;
    mapping(uint256 => string) _contentOf;

    mapping(uint256 => mapping(address => bool)) _shareToDao;
    mapping(uint256 => address[]) _shareDaoAddress;

    /* ============ External Functions ============ */


    function isViewerOf(address viewer, uint256 tokenId) external override view returns (bool) {
        return isOwnerOf(viewer, tokenId) ||
        _isFollowing(viewer, ownerOf(tokenId)) ||
        _isMemberOfDao(viewer, tokenId);
    }


    function contentOf(uint256 tokenId) external view returns (string memory){
        return _contentOf[tokenId];
    }


    function ownedPrepareToken(address owner) external view returns (uint256) {
        return _prepareToken[owner];
    }

    function setRegisterAddress(address _followRegister) external onlyOwner {
        followRegister = _followRegister;
    }

    function setShareToDao(uint256 tokenId, address daoAddress, bool isShare) external {
        require(isOwnerOf(msg.sender, tokenId), "PrivacyContent: caller is not owner");
        _shareToDao[tokenId][daoAddress] = isShare;
        _shareDaoAddress[tokenId].push(daoAddress);
    }

    function postPrivacy(uint256 tokenId, string memory object) external returns (uint256) {
        _checkPredicate(PRIVACY_DATA_PREDICATE, FieldType.STRING);
        require(tokenId > 0, "PrivacyContent:Token id not exist");
        require(_prepareToken[msg.sender] == tokenId, "PrivacyContent:Permission denied");
        require(_mintObject[msg.sender][object] == 0, "PrivacyContent:Already mint");
        _mintPrivacy(tokenId, PRIVACY_DATA_PREDICATE, string.concat(PRIVACY_PREFIX, object));
        delete _prepareToken[msg.sender];
        _mintObject[msg.sender][object] = tokenId;
        _contentOf[tokenId] = object;
        return tokenId;
    }

    function prepareToken() external returns (uint256) {
        require(_prepareToken[msg.sender] == 0, "PrivacyContent:Already prepared");
        uint256 tokenId = _addEmptyToken(msg.sender, 0);
        _prepareToken[msg.sender] = tokenId;
        return tokenId;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IPrivacyContent).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    /* ============ Internal Functions ============ */

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


    function _isFollowing(address viewer, address owner) internal view returns (bool){
        if (followRegister == address(0)) {
            return false;
        }
        address followContractAddress = IFollowRegister(followRegister).ownedFollowContract(owner);
        if (followContractAddress == address(0)) {
            return false;
        }

        return IFollow(followContractAddress).isFollowing(viewer);
    }

    function _isMemberOfDao(address viewer, uint256 tokenId) internal view returns (bool){
        address[] memory daoAddress = _shareDaoAddress[tokenId];
        for (uint256 i = 0; i < daoAddress.length; i++) {
            if (_shareToDao[tokenId][daoAddress[i]] && IDao(daoAddress[i]).isMember(viewer)) {
                return true;
            }
        }
        return false;
    }
}
