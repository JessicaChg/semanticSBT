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

    function setDaoInfo(string memory daoHash) external;

    function isFreeJoin() external view returns (bool);

    function addMember(address[] memory to) external;

    function join() external returns (uint256);

    function remove(address to) external returns (uint256);

    function isMember(address addr) external view returns (bool);
}