import {StringPO, SubjectPO} from "../core/SemanticBaseStruct.sol";


library ProfileLogic {

    uint256 constant ownerPredicateIndex = 1;
    uint256 constant namePredicateIndex = 2;
    uint256 constant avatarPredicateIndex = 3;
    uint256 constant connectionAddressPredicateIndex = 4;

    function generateStringPOList(string memory name, string memory avatar) external returns (StringPO[] memory){
        StringPO[] memory stringPOList = new StringPO[](2);
        stringPOList[0] = StringPO(namePredicateIndex, name);
        stringPOList[1] = StringPO(avatarPredicateIndex, avatar);
        return stringPOList;
    }

    function generateSubjectPOList(uint256 soulSubjectIndex, uint256 contractIndex) external returns (SubjectPO[] memory) {
        SubjectPO[] memory subjectPOList = new SubjectPO[](2);
        subjectPOList[0] = SubjectPO(ownerPredicateIndex, soulSubjectIndex);
        subjectPOList[1] = SubjectPO(connectionAddressPredicateIndex, contractIndex);
        return subjectPOList;
    }
}