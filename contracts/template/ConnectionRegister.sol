// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "../core/SemanticSBT.sol";
import "../interfaces/social/IConnectionRegister.sol";
import "../interfaces/social/IConnection.sol";
import {SocialGraphData} from "../libraries/SocialGraphData.sol";
import {DeployConnection} from "../libraries/DeployConnection.sol";
import {InitializeConnection} from "../libraries/InitializeConnection.sol";
import {SemanticSBTLogic} from "../libraries/SemanticSBTLogic.sol";

contract ConnectionRegister is IConnectionRegister, SemanticSBT {
    using Strings for uint256;
    using Strings for address;

    uint256 constant CONNECTION_CONTRACT_PREDICATE_INDEX = 1;

    uint256 constant soulCIndex = 1;
    uint256 constant contractCIndex = 2;

    mapping(address => address) _ownedConnectionContract;


    function ownedConnectionContract(address owner) external view returns (address){
        return _ownedConnectionContract[owner];
    }


    function deployConnectionContract(address to) external returns (uint256){
        require(_ownedConnectionContract[to] == address(0), "ConnectionRegister:Already deployed!");
        require(msg.sender == to || _minters[msg.sender], "Permission Denied");
        uint256 tokenId = _addEmptyToken(to, 0);
        address connectionAddress = DeployConnection.deployConnection();
        InitializeConnection.initConnection(connectionAddress, to, address(this));
        _ownedConnectionContract[to] = connectionAddress;
        uint256 contractIndex = _addSubject(connectionAddress.toHexString(), contractCIndex);

        SubjectPO[] memory subjectPOList = generateSubjectPOList(contractIndex);
        _mint(tokenId, to, new IntPO[](0), new StringPO[](0), new AddressPO[](0), subjectPOList, new BlankNodePO[](0));
    }


    function follow(address[] calldata addressList, bytes[] calldata datas) external returns (uint256[] memory){
        uint256[] memory tokenIds = new uint256[](addressList.length);
        for (uint256 i = 0; i < addressList.length; i++) {
            address connectionAddress = _ownedConnectionContract[addressList[i]];
            require(connectionAddress != address(0), string.concat(addressList[i].toHexString(), " does not have connection contract"));
            IConnection(connectionAddress).mint(msg.sender);
        }
        return tokenIds;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(SemanticSBT) returns (bool) {
        return interfaceId == type(IConnectionRegister).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    function generateSubjectPOList(uint256 contractIndex) internal returns (SubjectPO[] memory) {
        SubjectPO[] memory subjectPOList = new SubjectPO[](1);
        subjectPOList[0] = SubjectPO(CONNECTION_CONTRACT_PREDICATE_INDEX, contractIndex);
        return subjectPOList;
    }

}