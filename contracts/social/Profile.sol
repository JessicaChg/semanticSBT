// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "../core/SemanticSBT.sol";
import "../interfaces/social/IProfile.sol";
import "../interfaces/social/IConnection.sol";
import {SocialGraphData} from "../libraries/SocialGraphData.sol";
import {DeployConnection} from "../libraries/DeployConnection.sol";
import {InitializeConnection} from "../libraries/InitializeConnection.sol";
import {ProfileLogic} from "../libraries/ProfileLogic.sol";
import {SemanticSBTLogic} from "../libraries/SemanticSBTLogic.sol";

contract Profile is IProfile, SemanticSBT {
    using Strings for uint256;
    using Strings for address;


    uint256 constant ownerPredicateIndex = 1;
    uint256 constant namePredicateIndex = 2;
    uint256 constant avatarPredicateIndex = 3;
    uint256 constant nostrPredicateIndex = 4;
    uint256 constant connectionAddressPredicateIndex = 5;

    uint256 constant soulCIndex = 1;
    uint256 constant profileCIndex = 2;
    uint256 constant contractCIndex = 3;

    mapping(address => uint256) _ownedProfileId;
    mapping(uint256 => address) _connectionAddressByProfileId;

    function ownedProfileId(address owner) external view returns (uint256){
        return _ownedProfileId[owner];
    }

    function ownedConnectionAddress(uint256 profileId) external view returns (address){
        return _connectionAddressByProfileId[profileId];
    }


    function createProfile(SocialGraphData.Profile calldata profile) external returns (uint256){
        require(_ownedProfileId[profile.to] == 0, "Profile:Already created!");
        uint256 tokenId = _addEmptyToken(profile.to, 0);
        _ownedProfileId[profile.to] = tokenId;
        uint256 sIndex = _addSubject(tokenId.toString(), profileCIndex);
        address connectionAddress = DeployConnection.deployConnection();
        InitializeConnection.initConnection(connectionAddress, tokenId, profile.name);
        _connectionAddressByProfileId[tokenId] = connectionAddress;
        uint256 contractIndex = _addSubject(connectionAddress.toHexString(), contractCIndex);
        uint256 soulSubjectIndex = _addSubject(profile.to.toHexString(), soulCIndex);

        StringPO[] memory stringPOList = ProfileLogic.generateStringPOList(profile.name, profile.avatar);
        SubjectPO[] memory subjectPOList = ProfileLogic.generateSubjectPOList(soulSubjectIndex, soulSubjectIndex);
        _tokens[tokenId].sIndex = sIndex;
        _mint(tokenId, profile.to, new IntPO[](0), stringPOList, new AddressPO[](0), subjectPOList, new BlankNodePO[](0));
    }

    function setAvatar(string calldata avatar) external returns (bool){
        uint256 profileId = _ownedProfileId[msg.sender];
        SPO memory spo = _tokens[profileId];
        for (uint256 i = 0; i < spo.pIndex.length; i++) {
            if (spo.pIndex[i] == namePredicateIndex) {
                uint256 _oIndex = _stringO.length;
                _stringO.push(avatar);
                spo.oIndex[i] = _oIndex;
                string memory rdf = SemanticSBTLogic._buildRDF(spo, _classNames, _predicates, _stringO, _subjects, _blankNodeO);
                emit UpdateRDF(profileId, rdf);
                return true;
            }
        }
        return false;
    }

    function follow(uint256[] calldata profileIds, bytes[] calldata datas) external returns (uint256[] memory){
        uint256 profileId = _ownedProfileId[msg.sender];
        address connectionAddress = _connectionAddressByProfileId[profileId];
        uint256[] memory tokenIds = new uint256[](profileIds.length);
        for (uint256 i = 0; i < profileIds.length; i++) {
            IConnection(connectionAddress).mint(profileIds[i], ownerOf(profileIds[i]));
        }
        return tokenIds;
    }

    function followWithSig(SocialGraphData.FollowWithSigData calldata vars) external returns (uint256[] memory){

    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IProfile).interfaceId ||
        super.supportsInterface(interfaceId);
    }


}