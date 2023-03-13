// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../core/SemanticBaseStruct.sol";
import "../ISemanticSBT.sol";

interface IDao is ISemanticSBT {


    function initialize(
        address owner,
        address minter,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory schemaURI_,
        string[] memory classes_,
        Predicate[] memory predicates_
    ) external;

    function setDaoURI(string memory daoURI) external;

    function addMember(address[] memory addr) external;

    function join() external returns (uint256);

    function remove(address addr) external returns (uint256);

    function ownerTransfer(address to) external;

    function daoURI() external view returns (string memory);

    function ownerOfDao() external view returns (address);

    function isFreeJoin() external view returns (bool);

    function isMember(address addr) external view returns (bool);
}