// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./ISemanticSBT.sol";

/**
 * @dev Required interface of an ISemanticData compliant contract.
 *       interfaceId: 0x41be3f18
 */
interface ISemanticSBTPrivacy is ISemanticSBT {



    /**
     * @dev Returns if the `viewer` is allowed to view the `tokenId` .
     * @param viewer The viewer address
     * @param tokenId The token Id
     */
    function isViewerOf(address viewer, uint256 tokenId)
        external
        view
        returns (bool);
}
