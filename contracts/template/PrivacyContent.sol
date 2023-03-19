// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../interfaces/social/IPrivacyContent.sol";
import "../interfaces/social/IFollowRegister.sol";
import "../interfaces/social/IFollow.sol";
import "../interfaces/social/IDaoRegister.sol";
import "../interfaces/social/IDao.sol";

import "../core/SemanticSBTUpgradeable.sol";
import "../core/SemanticBaseStruct.sol";

contract PrivacyContent is IPrivacyContent, SemanticSBTUpgradeable {
    struct PrepareTokenWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
    }

    struct PostWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        uint256 tokenId;
        string content;
    }

    struct ShareToFollowerWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        uint256 tokenId;
        address followContractAddress;
    }

    struct ShareToDaoWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        uint256 tokenId;
        address daoContractAddress;
    }

    uint256 constant  PRIVACY_DATA_PREDICATE = 1;


    mapping(address => mapping(uint256 => bool)) internal _isViewerOf;
    mapping(address => uint256) internal _prepareToken;
    mapping(address => mapping(string => uint256)) internal _mintObject;
    mapping(uint256 => string) _contentOf;

    mapping(uint256 => mapping(address => bool)) _shareToDao;
    mapping(uint256 => mapping(address => bool)) _shareToFollow;
    mapping(uint256 => address[]) _shareDaoAddress;
    mapping(uint256 => address[]) _shareFollowAddress;
    mapping(uint256 => uint256) public sharedDaoAddressCount;
    mapping(uint256 => uint256) public sharedFollowAddressCount;

    bytes32 internal constant PREPARE_TOKEN_WITH_SIGN_TYPE_HASH = keccak256('PrepareTokenWithSign(uint256 nonce,uint256 deadline)');
    bytes32 internal constant POST_WITH_SIGN_TYPE_HASH = keccak256('PostWithSign(uint256 tokenId,string content,uint256 nonce,uint256 deadline)');
    bytes32 internal constant SHARE_TO_FOLLOW_WITH_SIGN_TYPE_HASH = keccak256('ShareToFollowerWithSign(uint256 tokenId,address followContractAddress,uint256 nonce,uint256 deadline)');
    bytes32 internal constant SHARE_TO_DAO_WITH_SIGN_TYPE_HASH = keccak256('ShareToDaoWithSign(uint256 tokenId,address daoContractAddress,uint256 nonce,uint256 deadline)');
    mapping(address => uint256) public nonces;
    /* ============ External Functions ============ */


    function isViewerOf(address viewer, uint256 tokenId) external override view returns (bool) {
        return isOwnerOf(viewer, tokenId) ||
        _isFollowing(viewer, tokenId) ||
        _isMemberOfDao(viewer, tokenId);
    }


    function contentOf(uint256 tokenId) external view returns (string memory){
        return _contentOf[tokenId];
    }


    function ownedPrepareToken(address owner) external view returns (uint256) {
        return _prepareToken[owner];
    }

    function prepareToken() external returns (uint256) {
        return _prepareTokenInternal(msg.sender);
    }


    function post(uint256 tokenId, string calldata content) external {
        _post(msg.sender, tokenId, content);
    }

    function shareToFollower(uint256 tokenId, address followContractAddress) external {
        _shareToFollowerInternal(msg.sender, tokenId, followContractAddress);
    }

    function shareToDao(uint256 tokenId, address daoAddress) external {
        _shareToDaoInternal(msg.sender, tokenId, daoAddress);
    }

    function sharedFollowAddressByIndex(uint256 tokenId, uint256 index) external view returns (address){
        return _shareFollowAddress[tokenId][index];
    }

    function sharedDaoAddressByIndex(uint256 tokenId, uint256 index) external view returns (address){
        return _shareDaoAddress[tokenId][index];
    }


    function prepareTokenWithSign(PrepareTokenWithSign calldata vars) external returns (uint256) {
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name(),
                address(this),
                keccak256(
                    abi.encode(
                        PREPARE_TOKEN_WITH_SIGN_TYPE_HASH,
                        nonces[vars.addr]++,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        return _prepareTokenInternal(addr);
    }

    function postWithSign(PostWithSign calldata vars) external {
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name(),
                address(this),
                keccak256(
                    abi.encode(
                        POST_WITH_SIGN_TYPE_HASH,
                        vars.tokenId,
                        keccak256(bytes(vars.content)),
                        nonces[vars.addr]++,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        _post(addr, vars.tokenId, vars.content);
    }


    function shareToFollowerWithSign(ShareToFollowerWithSign calldata vars) external {
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name(),
                address(this),
                keccak256(
                    abi.encode(
                        SHARE_TO_FOLLOW_WITH_SIGN_TYPE_HASH,
                        vars.tokenId,
                        vars.followContractAddress,
                        nonces[vars.addr]++,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        _shareToFollowerInternal(addr, vars.tokenId, vars.followContractAddress);
    }


    function shareToDaoWithSign(ShareToDaoWithSign calldata vars) external {
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name(),
                address(this),
                keccak256(
                    abi.encode(
                        SHARE_TO_DAO_WITH_SIGN_TYPE_HASH,
                        vars.tokenId,
                        vars.daoContractAddress,
                        nonces[vars.addr]++,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        _shareToDaoInternal(addr, vars.tokenId, vars.daoContractAddress);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBTUpgradeable) returns (bool) {
        return interfaceId == type(IPrivacyContent).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    /* ============ Internal Functions ============ */

    function _mintPrivacy(address addr, uint256 tokenId, uint256 pIndex, string memory object) internal {
        StringPO[] memory stringPOList = new StringPO[](1);
        stringPOList[0] = StringPO(pIndex, object);
        _mint(
            tokenId,
            addr,
            new IntPO[](0),
            stringPOList,
            new AddressPO[](0),
            new SubjectPO[](0),
            new BlankNodePO[](0)
        );
    }

    function _prepareTokenInternal(address addr) internal returns (uint256){
        require(_prepareToken[addr] == 0, "PrivacyContent:Already prepared");
        uint256 tokenId = _addEmptyToken(addr, 0);
        _prepareToken[addr] = tokenId;
        return tokenId;
    }

    function _post(address addr, uint256 tokenId, string memory content) internal {
        _checkPredicate(PRIVACY_DATA_PREDICATE, FieldType.STRING);
        require(tokenId > 0, "PrivacyContent:Token id not exist");
        require(_prepareToken[addr] == tokenId, "PrivacyContent:Permission denied");
        _mintPrivacy(addr, tokenId, PRIVACY_DATA_PREDICATE, content);
        delete _prepareToken[addr];
        _mintObject[addr][content] = tokenId;
        _contentOf[tokenId] = content;
    }

    function _shareToFollowerInternal(address addr, uint256 tokenId, address followContractAddress) internal {
        require(isOwnerOf(addr, tokenId), "PrivacyContent: caller is not owner");
        require(_shareFollowAddress[tokenId].length < 20, "PrivacyContent: shared to too many Follow contracts");
        _shareToFollow[tokenId][followContractAddress] = true;
        _shareFollowAddress[tokenId].push(followContractAddress);
        sharedFollowAddressCount[tokenId]++;
    }

    function _shareToDaoInternal(address addr, uint256 tokenId, address daoAddress) internal {
        require(isOwnerOf(addr, tokenId), "PrivacyContent: caller is not owner");
        require(_shareDaoAddress[tokenId].length < 20, "PrivacyContent: shared to too many DAOs");
        _shareToDao[tokenId][daoAddress] = true;
        _shareDaoAddress[tokenId].push(daoAddress);
        sharedDaoAddressCount[tokenId]++;
    }

    function _isFollowing(address viewer, uint256 tokenId) internal view returns (bool){
        address[] memory followContractAddress = _shareFollowAddress[tokenId];
        for (uint256 i = 0; i < followContractAddress.length; i++) {
            if (IFollow(followContractAddress[i]).isFollowing(viewer)) {
                return true;
            }
        }
        return false;
    }

    function _isMemberOfDao(address viewer, uint256 tokenId) internal view returns (bool){
        address[] memory daoAddress = _shareDaoAddress[tokenId];
        for (uint256 i = 0; i < daoAddress.length; i++) {
            if (IDao(daoAddress[i]).isMember(viewer)) {
                return true;
            }
        }
        return false;
    }
}
