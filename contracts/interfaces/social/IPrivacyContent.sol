// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "../ISemanticSBT.sol";

/**
 * @dev Required interface of an ISemanticData compliant contract.
 */
interface IPrivacyContent is ISemanticSBT {


    /**
     * @dev Returns if the `viewer` is allowed to view the `tokenId` .
     * @param viewer The viewer address
     * @param tokenId The token Id
     */
    function isViewerOf(address viewer, uint256 tokenId)
        external
        view
        returns (bool);

    function prepareToken() external returns (uint256);

    function ownedPrepareToken(address owner) external view returns (uint256);

    function postPrivacy(uint256 tokenId, string memory object) external returns (uint256);

}
