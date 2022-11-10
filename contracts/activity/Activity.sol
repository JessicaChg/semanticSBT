// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


import "../core/SemanticSBT.sol";
import "../core/SemanticBaseStruct.sol";

contract Activity is Ownable, Initializable, AccessControl {
    using Strings for uint256;
    using Strings for address;


    SemanticSBT _semanticSBT;
    bytes32 constant MINT_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000001;


    mapping(address => bool) public whiteList;
    address[] _whiteLists;

    uint256 private _pIndex;
    uint256 private _oIndex;


    mapping(address => mapping(uint256 => mapping(uint256 => bool)))  _mintedSPO;

    bool private _duplicatable;
    bool private _freeMintable;

    function initialize(
        address owner_,
        address semanticSBT_,
        string memory predicate,
        string memory subjectValue,
        string memory className
    ) public initializer onlyOwner {
        _grantRole(DEFAULT_ADMIN_ROLE, owner_);
        _grantRole(MINT_ROLE, owner_);

        _semanticSBT = SemanticSBT(semanticSBT_);
        _pIndex = _semanticSBT.predicateIndex(predicate);
        _oIndex = _semanticSBT.addSubject(subjectValue, className);
    }

    function duplicatable() public view returns (bool) {
        return _duplicatable;
    }

    function freeMintable() public view returns (bool) {
        return _freeMintable;
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
    onlyRole(getRoleAdmin(DEFAULT_ADMIN_ROLE)) {
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


    function mint() external {
        require(_freeMintable || whiteList[msg.sender], "Activity: permission denied");
        require(_duplicatable || !_mintedSPO[msg.sender][_pIndex][_oIndex], "Activity: already minted");
        _mintedSPO[msg.sender][_pIndex][_oIndex] = true;

        SubjectPO[] memory subjectPO = new SubjectPO[](1);
        subjectPO[0] = SubjectPO(_pIndex, _oIndex);

        _semanticSBT.mint(msg.sender, 0, new IntPO[](0), new StringPO[](0), new AddressPO[](0),
            subjectPO, new BlankNodePO[](0));
    }


}