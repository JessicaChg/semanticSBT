// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";

import "../core/SemanticSBT.sol";
import "../interfaces/social/INameService.sol";
import "../interfaces/social/IConnection.sol";
import {SocialGraphData} from "../libraries/SocialGraphData.sol";
import {DeployConnection} from "../libraries/DeployConnection.sol";
import {InitializeConnection} from "../libraries/InitializeConnection.sol";
import {SemanticSBTLogic} from "../libraries/SemanticSBTLogic.sol";
import {StringUtils} from "../libraries/StringUtils.sol";

contract NameService is INameService, SemanticSBT {
    using Strings for uint256;
    using Strings for address;
    using StringUtils for *;

    uint256 constant holdPredicateIndex = 1;
    uint256 constant resolvePredicateIndex = 2;

    uint256 constant soulCIndex = 1;
    uint256 constant domainCIndex = 2;

    uint256 _minDomainLength = 3;
    mapping(uint256 => uint256) _domainLengthControl;
    mapping(uint256 => uint256) _countOfDomainLength;

    mapping(address => mapping(uint256 => bool)) _ownedDomain;
    mapping(uint256 => address) _ownerOfDomain;
    mapping(uint256 => uint256) _tokenIdOfDomain;
    mapping(uint256 => uint256) _domainOf;

    mapping(address => uint256) _ownedResolvedDomain;
    mapping(uint256 => address) _ownerOfResolvedDomain;
    mapping(uint256 => uint256) _tokenIdOfResolvedDomain;

    function setDomainLengthControl(uint256 minDomainLength_, uint256 _domainLength, uint256 _maxCount) external onlyMinter {
        _minDomainLength = minDomainLength_;
        _domainLengthControl[_domainLength] = _maxCount;
    }


    function register(address owner, string calldata name, bool resolve) external override returns (uint) {
        require(_minters[msg.sender] || _checkValidLength(name), "NameService: invalid length of name");
        require(_subjectIndex[domainCIndex][name] == 0, "NameService: already added");
        uint256 sIndex = _addSubject(name, domainCIndex);
        _ownedDomain[owner][sIndex] = true;
        _ownerOfDomain[sIndex] = owner;
        uint256 tokenId = _addEmptyToken(owner, 0);
        _tokenIdOfDomain[sIndex] = tokenId;
        _domainOf[tokenId] = sIndex;
        SubjectPO[] memory subjectPOList;
        if (resolve) {
            _setNameForAddr(owner, owner, sIndex);
            subjectPOList = new SubjectPO[](2);
            subjectPOList[0] = SubjectPO(holdPredicateIndex, sIndex);
            subjectPOList[1] = SubjectPO(resolvePredicateIndex, sIndex);
        } else {
            subjectPOList = new SubjectPO[](1);
            subjectPOList[0] = SubjectPO(holdPredicateIndex, sIndex);
        }
        _mint(tokenId, owner, new IntPO[](0), new StringPO[](0), new AddressPO[](0), subjectPOList, new BlankNodePO[](0));
    }


    function setNameForAddr(address addr, string memory name) external override {
        require(addr == msg.sender || addr == address(0), "NameService:can not set for others");
        uint256 sIndex = _subjectIndex[domainCIndex][name];
        uint256 tokenId = _tokenIdOfDomain[sIndex];
        SPO storage spo = _tokens[tokenId];
        _setNameForAddr(addr, msg.sender, sIndex);
        if (addr != address(0)) {
            spo.pIndex.push(resolvePredicateIndex);
            spo.oIndex.push(sIndex);
        } else {
            for (uint256 i = 0; i < spo.pIndex.length; i ++) {
                if (spo.pIndex[i] == resolvePredicateIndex) {
                    spo.pIndex[i] = spo.pIndex[spo.pIndex.length - 1];
                    spo.oIndex[i] = spo.oIndex[spo.oIndex.length - 1];
                    spo.pIndex.pop();
                    spo.oIndex.pop();
                    break;
                }
            }
        }
        emit UpdateRDF(tokenId, SemanticSBTLogic.buildRDF(spo, _classNames, _predicates, _stringO, _subjects, _blankNodeO));
    }


    function addr(string calldata name) virtual override external view returns (address){
        uint256 sIndex = _subjectIndex[domainCIndex][name];
        return _ownerOfResolvedDomain[sIndex];
    }


    function nameOf(address addr) external view returns (string memory){
        uint256 sIndex = _ownedResolvedDomain[addr];
        return _subjects[sIndex].value;
    }

    function setProfileHash(string memory) external view returns (string memory){

    }

    function profileHash(address addr) external view returns (string memory){

    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(INameService).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override virtual {
        require(_ownerOfResolvedDomain[_domainOf[tokenId]] == address(0), "NameService:can not transfer when resolved");
        super._transfer(from, to, tokenId);
        _ownerOfDomain[_domainOf[tokenId]] == to;
        _ownedDomain[to][_domainOf[tokenId]] = true;
    }


    function _setNameForAddr(address addr, address owner, uint256 domainSIndex) private {
        require(_ownerOfDomain[domainSIndex] == owner, "NameService:not the owner of domain");
        require(_ownerOfResolvedDomain[domainSIndex] == address(0), "NameService:already resolved");
        _ownedResolvedDomain[addr] = domainSIndex;
        _ownerOfResolvedDomain[domainSIndex] = addr;
        _tokenIdOfResolvedDomain[domainSIndex] = _tokenIdOfDomain[domainSIndex];
    }

    function _checkValidLength(string memory name) internal view returns (bool){
        uint256 len = name.strlen();
        if (len < _minDomainLength) {
            return false;
        }
        if (_domainLengthControl[len] == 0) {
            return true;
        } else if (_domainLengthControl[len] - _countOfDomainLength[len] > 0) {
            return true;
        }
        return false;
    }


}