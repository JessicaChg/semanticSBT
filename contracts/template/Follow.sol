// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../core/SemanticSBT.sol";
import "../interfaces/social/IFollow.sol";

contract Follow is IFollow, SemanticSBT {

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

    bytes32 internal constant FOLLOW_WITH_SIG_TYPE_HASH = keccak256('followWithSign()');
    bytes32 internal constant UNFOLLOW_WITH_SIG_TYPE_HASH = keccak256('unfollowWithSign()');
    bytes32 internal constant EIP712_DOMAIN_TYPE_HASH = keccak256('EIP712Domain(uint256 chainId,address verifyingContract)');
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
        _follow(msg.sender);
    }

    function unfollow() external {
        _unfollow(msg.sender);
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


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IFollow).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    function _setOwner(address owner) internal {
        uint256 sIndex = _addSubject(owner.toHexString(), SOUL_CLASS_INDEX);
        ownerSubjectPO.push(SubjectPO(FOLLOWING_PREDICATE_INDEX, sIndex));
    }

    function _follow(address addr) internal {
        require(!_isFollowing[addr], "Follow:Already followed!");
        _isFollowing[addr] = true;
        uint256 sIndex = _subjectIndex[SOUL_CLASS_INDEX][addr.toHexString()];
        if (sIndex == 0) {
            sIndex = _addSubject(addr.toHexString(), SOUL_CLASS_INDEX);
        }
        uint256 tokenId = _addEmptyToken(addr, sIndex);
        _mint(tokenId, msg.sender, new IntPO[](0), new StringPO[](0), new AddressPO[](0), ownerSubjectPO, new BlankNodePO[](0));
    }

    function _unfollow(address addr) internal {
        uint256 tokenId = tokenOfOwnerByIndex(addr, 0);
        super._burn(msg.sender, tokenId);
        _isFollowing[addr] = false;
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