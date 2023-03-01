// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


import "../core/SemanticSBTPrivacy.sol";

contract SharePrivacy is SemanticSBTPrivacy {

    /* ============ External Functions ============ */


    function mintPrivacy(uint256 tokenId, uint256 pIndex, string memory object) external returns (uint256) {
        _checkPredicate(pIndex, FieldType.STRING);
        require(tokenId > 0, "SharePrivacy:Token id not exist");
        require(_prepareToken[msg.sender] == tokenId, "SharePrivacy:Permission denied");
        require(_mintObject[msg.sender][object] == 0, "SharePrivacy:Already mint");
        _mintPrivacy(tokenId, pIndex, string.concat(PRIVACY_PREFIX, object));
        delete _prepareToken[msg.sender];
        _mintObject[msg.sender][object] = tokenId;
        return tokenId;
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
}
