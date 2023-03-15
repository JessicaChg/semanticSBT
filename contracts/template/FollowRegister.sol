// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";

import "../core/SemanticSBT.sol";
import "../interfaces/social/IFollowRegister.sol";
import "../interfaces/social/IFollow.sol";
import {SocialGraphData} from "../libraries/SocialGraphData.sol";
import {DeployFollow} from "../libraries/DeployFollow.sol";
import {InitializeFollow} from "../libraries/InitializeFollow.sol";
import {SemanticSBTLogic} from "../libraries/SemanticSBTLogic.sol";

contract FollowRegister is IFollowRegister, SemanticSBT {
    using Strings for uint256;
    using Strings for address;

    uint256 constant FOLLOW_CONTRACT_PREDICATE_INDEX = 1;

    uint256 constant SOUL_CLASS_INDEX = 1;
    uint256 constant CONTRACT_CLASS_INDEX = 2;

    mapping(address => address) _ownedFollowContract;


    function ownedFollowContract(address owner) external view returns (address){
        return _ownedFollowContract[owner];
    }


    function deployFollowContract(address to) external returns (uint256){
        require(_ownedFollowContract[to] == address(0), "FollowRegister:Already deployed!");
        require(msg.sender == to || _minters[msg.sender], "FollowRegister:Permission Denied");
        uint256 tokenId = _addEmptyToken(to, 0);
        address followContractAddress = DeployFollow.deployFollow();
        InitializeFollow.initFollow(followContractAddress, to, address(this));
        _ownedFollowContract[to] = followContractAddress;
        uint256 contractIndex = _addSubject(followContractAddress.toHexString(), CONTRACT_CLASS_INDEX);

        SubjectPO[] memory subjectPOList = generateSubjectPOList(contractIndex);
        _mint(tokenId, to, new IntPO[](0), new StringPO[](0), new AddressPO[](0), subjectPOList, new BlankNodePO[](0));
        return tokenId;
    }



    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IFollowRegister).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    function generateSubjectPOList(uint256 contractIndex) internal pure returns (SubjectPO[] memory) {
        SubjectPO[] memory subjectPOList = new SubjectPO[](1);
        subjectPOList[0] = SubjectPO(FOLLOW_CONTRACT_PREDICATE_INDEX, contractIndex);
        return subjectPOList;
    }

}