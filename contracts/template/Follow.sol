// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../core/SemanticSBTUpgradeable.sol";
import "../interfaces/social/IFollow.sol";

contract Follow is IFollow, SemanticSBTUpgradeable {

    using Strings for uint256;
    using Strings for address;

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }


    SubjectPO[] private ownerSubjectPO;

    uint256 constant FOLLOWING_PREDICATE_INDEX = 1;

    uint256 constant SOUL_CLASS_INDEX = 1;

    mapping(address => bool) _isFollowing;
    address public representedAddress;


    bytes32 internal constant FOLLOW_WITH_SIG_TYPE_HASH = keccak256('followWithSign()');
    bytes32 internal constant UNFOLLOW_WITH_SIG_TYPE_HASH = keccak256('unfollowWithSign()');
    bytes32 internal constant EIP712_DOMAIN_TYPE_HASH = keccak256('EIP712Domain(uint256 chainId,address verifyingContract)');
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


    function follow() external returns (uint256){
        return _follow(msg.sender);
    }

    function unfollow() external returns (uint256){
        return _unfollow(msg.sender);
    }

    function followWithSign(Signature calldata sig) external {
        address addr = _recoverSignerFromSignature(sig, FOLLOW_WITH_SIG_TYPE_HASH);
        _follow(addr);
    }

    function unfollowWithSign(Signature calldata sig) external {
        address addr = _recoverSignerFromSignature(sig, UNFOLLOW_WITH_SIG_TYPE_HASH);
        _unfollow(addr);
    }


    function isFollowing(address addr) external view returns (bool){
        return _isFollowing[addr];
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBTUpgradeable) returns (bool) {
        return interfaceId == type(IFollow).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    function _setOwner(address owner) internal {
        uint256 sIndex = SemanticSBTLogicUpgradeable.addSubject(owner.toHexString(), SOUL_CLASS_NAME, _subjects, _subjectIndex, _classIndex);
        ownerSubjectPO.push(SubjectPO(FOLLOWING_PREDICATE_INDEX, sIndex));
        representedAddress = owner;
    }

    function _follow(address addr) internal returns (uint256){
        require(!_isFollowing[addr], "Follow:Already followed!");
        _isFollowing[addr] = true;
        uint256 tokenId = _addEmptyToken(addr, 0);
        _mint(tokenId, addr, new IntPO[](0), new StringPO[](0), new AddressPO[](0), ownerSubjectPO, new BlankNodePO[](0));
        return tokenId;
    }

    function _unfollow(address addr) internal returns (uint256){
        uint256 tokenId = tokenOfOwnerByIndex(addr, 0);
        super._burn(addr, tokenId);
        _isFollowing[addr] = false;
        return tokenId;
    }


    function _recoverSignerFromSignature(Signature memory sig, bytes32 typeHash) internal view returns (address){
        require(sig.deadline < block.timestamp, "Follow: permission denied");
        address signer = _recoverSigner(_calculateHashMessage(typeHash, sig.deadline),
            sig.v,
            sig.r,
            sig.s);
        return signer;
    }


    function _calculateHashMessage(bytes32 typeHash, uint256 deadline) internal view returns (bytes32) {
        return
        keccak256(
            abi.encode(
                _calculateDomainSeparator(),
                typeHash,
                deadline
            )
        );
    }

    function _calculateDomainSeparator() internal view returns (bytes32){
        return
        keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPE_HASH,
                address(this),
                block.chainid
            )
        );
    }

    function _recoverSigner(
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(
            abi.encodePacked(prefix, _hashedMessage)
        );
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

}