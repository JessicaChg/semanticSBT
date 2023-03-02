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

    function invite(string memory whiteListURL, bytes32 root) external;

    function join(bytes32[] calldata proof) external returns (uint256);

    function quit(address to) external returns (uint256);

    function isMember(address addr) external view returns (bool);
}