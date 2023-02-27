import "../core/SemanticBaseStruct.sol";
import {StringUtils} from "./StringUtils.sol";


library NameServiceLogic {
    using StringUtils for *;

    uint256 constant holdPredicateIndex = 1;
    uint256 constant resolvePredicateIndex = 2;

    function checkValidLength(string memory name,
        uint256 _minDomainLength,
        mapping(uint256 => uint256) storage _domainLengthControl,
        mapping(uint256 => uint256) storage _countOfDomainLength) internal view returns (bool){
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


    function setNameForAddr(address addr, address owner, uint256 dSIndex,
        mapping(uint256 => uint256) storage _tokenIdOfDomain, mapping(address => uint256) storage _ownedResolvedDomain,
        mapping(uint256 => address) storage _ownerOfResolvedDomain, mapping(uint256 => uint256) storage _tokenIdOfResolvedDomain) internal {
        require(_ownerOfResolvedDomain[dSIndex] == address(0), "NameService:already resolved");
        _ownedResolvedDomain[addr] = dSIndex;
        _ownerOfResolvedDomain[dSIndex] = addr;
        _tokenIdOfResolvedDomain[dSIndex] = _tokenIdOfDomain[dSIndex];
    }

    function updatePIndexOfToken(address addr, uint256 tokenId, SPO storage spo) internal {
        if (addr == address(0)) {
            spo.pIndex[0] = holdPredicateIndex;
        } else {
            spo.pIndex[0] = resolvePredicateIndex;
        }
    }


    function register(uint256 tokenId, address owner, uint256 sIndex, bool resolve,
        mapping(uint256 => uint256) storage _tokenIdOfDomain,
        mapping(uint256 => uint256) storage _domainOf,
        mapping(address => uint256) storage _ownedResolvedDomain,
        mapping(uint256 => address) storage _ownerOfResolvedDomain,
        mapping(uint256 => uint256) storage _tokenIdOfResolvedDomain,
        string memory name,
        uint256 _minDomainLength,
        mapping(uint256 => uint256) storage _domainLengthControl,
        mapping(uint256 => uint256) storage _countOfDomainLength) internal returns (SubjectPO[] memory) {
        require(checkValidLength(name, _minDomainLength, _domainLengthControl, _countOfDomainLength), "NameService: invalid length of name");
        _tokenIdOfDomain[sIndex] = tokenId;
        _domainOf[tokenId] = sIndex;
        SubjectPO[] memory subjectPOList = new SubjectPO[](1);
        if (resolve) {
            setNameForAddr(owner, owner, sIndex, _tokenIdOfDomain, _ownedResolvedDomain,
                _ownerOfResolvedDomain, _tokenIdOfResolvedDomain);
            subjectPOList[0] = SubjectPO(resolvePredicateIndex, sIndex);
        } else {
            subjectPOList[0] = SubjectPO(holdPredicateIndex, sIndex);
        }
        return subjectPOList;
    }
}