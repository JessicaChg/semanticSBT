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

    uint256 constant CONNECTION_CONTRACT_PREDICATE_INDEX = 1;

    uint256 constant soulCIndex = 1;
    uint256 constant contractCIndex = 2;

    mapping(address => address) _ownedFollowContract;


    function ownedFollowContract(address owner) external view returns (address){
        return _ownedFollowContract[owner];
    }


    function deployFollowContract(address to) external returns (uint256){
        require(_ownedFollowContract[to] == address(0), "FollowRegister:Already deployed!");
        require(msg.sender == to || _minters[msg.sender], "FollowRegister:Permission Denied");
        uint256 tokenId = _addEmptyToken(to, 0);
        address connectionAddress = DeployFollow.deployFollow();
        InitializeFollow.initFollow(connectionAddress, to, address(this));
        _ownedFollowContract[to] = connectionAddress;
        uint256 contractIndex = _addSubject(connectionAddress.toHexString(), contractCIndex);

        SubjectPO[] memory subjectPOList = generateSubjectPOList(contractIndex);
        _mint(tokenId, to, new IntPO[](0), new StringPO[](0), new AddressPO[](0), subjectPOList, new BlankNodePO[](0));
        return tokenId;
    }

    function follow(address[] calldata followingIds) external returns (uint256[] memory){

    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IFollowRegister).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    function generateSubjectPOList(uint256 contractIndex) internal pure returns (SubjectPO[] memory) {
        SubjectPO[] memory subjectPOList = new SubjectPO[](1);
        subjectPOList[0] = SubjectPO(CONNECTION_CONTRACT_PREDICATE_INDEX, contractIndex);
        return subjectPOList;
    }

}