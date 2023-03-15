// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../core/SemanticBaseStruct.sol";
import "../ISemanticSBT.sol";

interface IFollow is ISemanticSBT {


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

    /**
     * Follow the owner of the current contract.
     * @return tokenId
     */
    function follow() external returns (uint256);

    /**
     * Unfollow
     * @return tokenId
     */
    function unfollow() external returns (uint256);

    /**
     * Returns whether the `addr` is following the owner of the current contract
     * @return isFollowing
     */
    function isFollowing(address addr) external view returns (bool);

}