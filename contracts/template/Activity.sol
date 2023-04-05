// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


import "../interfaces/social/IActivity.sol";
import "../core/SemanticSBT.sol";
import "../core/SemanticBaseStruct.sol";

contract Activity is IActivity, SemanticSBT {
    using Strings for uint256;
    using Strings for address;


    uint256 _soulCIndex = 1;
    uint256 _activityCIndex = 2;
    uint256 _pIndex = 1;
    uint256 _oIndex = 1;


    mapping(address => mapping(uint256 => mapping(uint256 => bool)))  _mintedSPO;

    bool private _duplicatable;
    bool private _freeMintable;

    mapping(address => bool) public whiteList;
    address[] _whiteLists;

    function duplicatable() public view returns (bool) {
        return _duplicatable;
    }

    function freeMintable() public view returns (bool) {
        return _freeMintable;
    }


    function setActivity(string memory activityName) external onlyMinter {
        require(getMinted() == 0, "Activity:can not set activity after minted!");
        _oIndex = SemanticSBTLogic.addSubject(activityName, _classNames[_activityCIndex], _subjects, _subjectIndex, _classIndex);
    }

    function whiteListRange(uint256 offset, uint256 limit) public view returns (address[] memory whiteList_){
        if (offset > _whiteLists.length) {
            return new address[](0);
        }
        uint256 end = (offset + limit) > _whiteLists.length ? _whiteLists.length : offset + limit;
        limit = (offset + limit) > _whiteLists.length ? (_whiteLists.length - offset) : limit;
        whiteList_ = new address[](limit);
        for (uint256 i = offset; i < end; i++) {
            whiteList_[i - offset] = _whiteLists[i];
        }
    }

    function addWhiteList(address[] memory addressList) external
    onlyMinter {
        for (uint256 i = 0; i < addressList.length; i++) {
            if (!whiteList[addressList[i]]) {
                whiteList[addressList[i]] = true;
                _whiteLists.push(addressList[i]);
            }
        }
    }

    function setDuplicatable(bool duplicatable_) external onlyOwner {
        _duplicatable = duplicatable_;
    }


    function setFreeMintable(bool freeMintable_) external onlyOwner {
        _freeMintable = freeMintable_;
    }


    function participate() external {
        require(_freeMintable || whiteList[msg.sender], "Activity: permission denied");
        require(_duplicatable || !_mintedSPO[msg.sender][_pIndex][_oIndex], "Activity: already minted");
        _mintedSPO[msg.sender][_pIndex][_oIndex] = true;

        SubjectPO[] memory subjectPO = new SubjectPO[](1);
        subjectPO[0] = SubjectPO(_pIndex, _oIndex);

        uint256 tokenId = _addEmptyToken(msg.sender, 0);

        _mint(tokenId, msg.sender, new IntPO[](0), new StringPO[](0), new AddressPO[](0),
            subjectPO, new BlankNodePO[](0));

    }

}