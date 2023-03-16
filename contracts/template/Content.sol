// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../interfaces/social/IContent.sol";
import "../core/SemanticSBT.sol";
import "../core/SemanticBaseStruct.sol";

contract Content is IContent, SemanticSBT {

    struct PrepareTokenWithSign {
        SemanticSBTLogic.Signature sig;
        address addr;
    }

    struct PostWithSign {
        SemanticSBTLogic.Signature sig;
        address addr;
        string content;
    }

    uint256 constant  PUBLIC_CONTENT_PREDICATE = 1;

    mapping(address => mapping(string => uint256)) internal _mintContent;
    mapping(uint256 => string) _contentOf;

    bytes32 internal constant POST_WITH_SIGN_TYPE_HASH = keccak256('PostWithSign(string content,uint256 nonce,uint256 deadline)');
    mapping(address => uint256) public nonces;


    /* ============ External Functions ============ */

    function post(string memory content) external {
        _post(msg.sender, content);
    }


    function postWithSign(PostWithSign calldata vars) external {
        address addr;
        unchecked {
            addr = SemanticSBTLogic.recoverSignerFromSignature(
                name(),
                address(this),
                keccak256(
                    abi.encode(
                        POST_WITH_SIGN_TYPE_HASH,
            keccak256(bytes(vars.content)),
                        nonces[vars.addr]++,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        _post(addr, vars.content);
    }


    function contentOf(uint256 tokenId) external view returns (string memory){
        return _contentOf[tokenId];
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IContent).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    /* ============ Internal Functions ============ */

    function _post(address addr, string memory content) internal {
        _checkPredicate(PUBLIC_CONTENT_PREDICATE, FieldType.STRING);
        uint256 tokenId = _addEmptyToken(addr, 0);
        _mint(tokenId, PUBLIC_CONTENT_PREDICATE, content);
        _mintContent[addr][content] = tokenId;
        _contentOf[tokenId] = content;
    }

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
