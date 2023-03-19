// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "../core/SemanticSBTUpgradeable.sol";
import "../interfaces/social/INameService.sol";
import {SemanticSBTLogicUpgradeable} from "../libraries/SemanticSBTLogicUpgradeable.sol";
import {NameServiceLogic} from "../libraries/NameServiceLogic.sol";


contract NameService is INameService, SemanticSBTUpgradeable {
    using StringsUpgradeable for uint256;
    using StringsUpgradeable for address;

    uint256 constant HOLD_PREDICATE_INDEX = 1;
    uint256 constant RESOLVED_PREDICATE_INDEX = 2;
    uint256 constant PROFILE_URI_PREDICATE_INDEX = 3;

    uint256 constant SOUL_CLASS_INDEX = 1;
    uint256 constant DOMAIN_CLASS_INDEX = 2;


    uint256 _minNameLength;
    mapping(uint256 => uint256) _nameLengthControl;
    mapping(uint256 => uint256) _countOfNameLength;
    string public suffix;

    mapping(uint256 => uint256) _tokenIdOfName;
    mapping(uint256 => uint256) _nameOf;

    mapping(address => uint256) _ownedResolvedName;
    mapping(uint256 => address) _ownerOfResolvedName;
    mapping(uint256 => uint256) _tokenIdOfResolvedName;

    mapping(address => string) _profileURI;
    mapping(address => bool) _ownedProfileURI;

    function setSuffix(string calldata suffix_) external onlyMinter {
        suffix = suffix_;
    }

    function setNameLengthControl(uint256 minNameLength_, uint256 _nameLength, uint256 _maxCount) external onlyMinter {
        _minNameLength = minNameLength_;
        _nameLengthControl[_nameLength] = _maxCount;
    }


    function register(address owner, string calldata name, bool resolve) external override returns (uint tokenId) {
        require(NameServiceLogic.checkValidLength(name, _minNameLength, _nameLengthControl, _countOfNameLength), "NameService: invalid length of name");
        string memory fullName = string.concat(name, suffix);
        require(_subjectIndex[DOMAIN_CLASS_INDEX][fullName] == 0, "NameService: already added");
        tokenId = _addEmptyToken(owner, 0);
        uint256 sIndex = SemanticSBTLogicUpgradeable._addSubject(fullName, DOMAIN_CLASS_INDEX, _subjects, _subjectIndex);
        SubjectPO[] memory subjectPOList = NameServiceLogic.register(tokenId, owner, sIndex, resolve,
            _tokenIdOfName, _nameOf,
            _ownedResolvedName, _ownerOfResolvedName, _tokenIdOfResolvedName
        );
        _mint(tokenId, owner, new IntPO[](0), new StringPO[](0), new AddressPO[](0), subjectPOList, new BlankNodePO[](0));
    }


    function setNameForAddr(address addr_, string calldata name) external override {
        require(addr_ == msg.sender || addr_ == address(0), "NameService:can not set for others");
        uint256 sIndex = _subjectIndex[DOMAIN_CLASS_INDEX][name];
        uint256 tokenId = _tokenIdOfName[sIndex];
        require(ownerOf(tokenId) == msg.sender, "NameService:not the owner");
        SPO storage spo = _tokens[tokenId];
        NameServiceLogic.setNameForAddr(addr_, sIndex, _tokenIdOfName, _ownedResolvedName,
            _ownerOfResolvedName, _tokenIdOfResolvedName);
        NameServiceLogic.updatePIndexOfToken(addr_, spo);
        emit UpdateRDF(tokenId, SemanticSBTLogicUpgradeable.buildRDF(spo, _classNames, _predicates, _stringO, _subjects, _blankNodeO));
    }

    function setProfileURI(string calldata profileURI_) external {
        _profileURI[msg.sender] = profileURI_;
        string memory rdf = SemanticSBTLogicUpgradeable.buildStringRDFCustom(SOUL_CLASS_NAME, msg.sender.toHexString(), _predicates[PROFILE_URI_PREDICATE_INDEX].name, string.concat('"', profileURI_, '"'));
        if (!_ownedProfileURI[msg.sender]) {
            _ownedProfileURI[msg.sender] = true;
            emit CreateRDF(0, rdf);
        } else {
            emit UpdateRDF(0, rdf);
        }
    }


    function addr(string calldata name) virtual override external view returns (address){
        uint256 sIndex = _subjectIndex[DOMAIN_CLASS_INDEX][name];
        return _ownerOfResolvedName[sIndex];
    }


    function nameOf(address addr_) external view returns (string memory){
        if (addr_ == address(0)) {
            return "";
        }
        uint256 sIndex = _ownedResolvedName[addr_];
        return _subjects[sIndex].value;
    }

    function nameOfTokenId(uint256 tokenId) external view returns (string memory){
        return _subjects[_nameOf[tokenId]].value;
    }

    function profileURI(address addr_) external view returns (string memory){
        return _profileURI[addr_];
    }


    function ownerOfName(string calldata name) external view returns (address){
        uint256 sIndex = _subjectIndex[DOMAIN_CLASS_INDEX][name];
        uint256 tokenId = _tokenIdOfName[sIndex];
        return ownerOf(tokenId);
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBTUpgradeable) returns (bool) {
        return interfaceId == type(INameService).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(SemanticSBTUpgradeable) virtual {
        require(_ownerOfResolvedName[_nameOf[tokenId]] == address(0), "NameService:can not transfer when resolved");
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(SemanticSBTUpgradeable) virtual {
        emit UpdateRDF(tokenId, SemanticSBTLogicUpgradeable.buildRDF(_tokens[tokenId], _classNames, _predicates, _stringO, _subjects, _blankNodeO));
    }


}