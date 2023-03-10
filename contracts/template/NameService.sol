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

    uint256 constant holdPredicateIndex = 1;
    uint256 constant resolvePredicateIndex = 2;
    uint256 constant profileHashPredicateIndex = 3;

    uint256 constant soulCIndex = 1;
    uint256 constant domainCIndex = 2;


    uint256 _minDomainLength;
    mapping(uint256 => uint256) _domainLengthControl;
    mapping(uint256 => uint256) _countOfDomainLength;
    string _suffix;

    mapping(uint256 => uint256) _tokenIdOfDomain;
    mapping(uint256 => uint256) _domainOf;

    mapping(address => uint256) _ownedResolvedDomain;
    mapping(uint256 => address) _ownerOfResolvedDomain;
    mapping(uint256 => uint256) _tokenIdOfResolvedDomain;

    mapping(address => string) _profileHash;

    function setSuffix(string calldata suffix_) external onlyMinter {
        _suffix = suffix_;
    }

    function setDomainLengthControl(uint256 minDomainLength_, uint256 _domainLength, uint256 _maxCount) external onlyMinter {
        _minDomainLength = minDomainLength_;
        _domainLengthControl[_domainLength] = _maxCount;
    }


    function register(address owner, string calldata name, bool resolve) external override returns (uint tokenId) {
        require(_subjectIndex[domainCIndex][name] == 0, "NameService: already added");
        tokenId = _addEmptyToken(owner, 0);
        uint256 sIndex = SemanticSBTLogicUpgradeable._addSubject(name, domainCIndex, _subjects, _subjectIndex);
        SubjectPO[] memory subjectPOList = NameServiceLogic.register(tokenId, owner, sIndex, resolve,
            _tokenIdOfDomain, _domainOf,
            _ownedResolvedDomain, _ownerOfResolvedDomain, _tokenIdOfResolvedDomain,
            name, _minDomainLength, _domainLengthControl, _countOfDomainLength
        );
        _mint(tokenId, owner, new IntPO[](0), new StringPO[](0), new AddressPO[](0), subjectPOList, new BlankNodePO[](0));
    }


    function setNameForAddr(address addr_, string memory name) external override {
        require(addr_ == msg.sender || addr_ == address(0), "NameService:can not set for others");
        uint256 sIndex = _subjectIndex[domainCIndex][name];
        uint256 tokenId = _tokenIdOfDomain[sIndex];
        require(ownerOf(tokenId) == msg.sender, "NameService:not the owner");
        SPO storage spo = _tokens[tokenId];
        NameServiceLogic.setNameForAddr(addr_, sIndex, _tokenIdOfDomain, _ownedResolvedDomain,
            _ownerOfResolvedDomain, _tokenIdOfResolvedDomain);
        NameServiceLogic.updatePIndexOfToken(addr_, spo);
        emit UpdateRDF(tokenId, SemanticSBTLogicUpgradeable.buildRDF(spo, _classNames, _predicates, _stringO, _subjects, _blankNodeO));
    }

    function setProfileHash(string memory profileHash) external {
        require(_ownedResolvedDomain[msg.sender] != 0, "NameService:not resolved the domain");
        _profileHash[msg.sender] = profileHash;
        emit SetProfile(msg.sender, profileHash);
        string memory s = string.concat(SemanticSBTLogicUpgradeable.ENTITY_PREFIX, SOUL_CLASS_NAME, SemanticSBTLogicUpgradeable.CONCATENATION_CHARACTER, msg.sender.toHexString(), SemanticSBTLogicUpgradeable.BLANK_SPACE);
        string memory p = string.concat(SemanticSBTLogicUpgradeable.PROPERTY_PREFIX, _predicates[profileHashPredicateIndex].name, SemanticSBTLogicUpgradeable.BLANK_SPACE);
        string memory o = string.concat('"', profileHash, '"');
        emit UpdateRDF(0, string.concat(s, p, o, SemanticSBTLogicUpgradeable.TURTLE_END_SUFFIX));
    }


    function addr(string calldata name) virtual override external view returns (address){
        uint256 sIndex = _subjectIndex[domainCIndex][name];
        return _ownerOfResolvedDomain[sIndex];
    }


    function nameOf(address addr_) external view returns (string memory){
        uint256 sIndex = _ownedResolvedDomain[addr_];
        return string.concat(_subjects[sIndex].value, _suffix);
    }

    function profileHash(address addr_) external view returns (string memory){
        return _profileHash[addr_];
    }


    function ownerOfName(string calldata name) external view returns (address){
        uint256 sIndex = _subjectIndex[domainCIndex][name];
        uint256 tokenId = _tokenIdOfDomain[sIndex];
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
        require(_ownerOfResolvedDomain[_domainOf[tokenId]] == address(0), "NameService:can not transfer when resolved");
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(SemanticSBTUpgradeable) virtual {
        emit UpdateRDF(tokenId, SemanticSBTLogicUpgradeable.buildRDF(_tokens[tokenId], _classNames, _predicates, _stringO, _subjects, _blankNodeO));
    }


}