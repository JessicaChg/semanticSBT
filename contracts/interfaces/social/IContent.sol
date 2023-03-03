// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "../ISemanticSBT.sol";

/**
 * @dev Required interface of an ISemanticData compliant contract.
 */
interface IContent is ISemanticSBT {


    function prepareToken() external returns (uint256);

    function ownedPrepareToken(address owner) external view returns (uint256);

    function post(uint256 tokenId, string memory object) external returns (uint256);

    function contentOf(uint256 tokenId) external view returns (string memory);
}
