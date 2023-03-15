// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "../ISemanticSBT.sol";


interface IPrivacyContent is ISemanticSBT {

    /**
     * Prepare a tokenId.
     * @return tokenId The prepared tokenId.
     */
    function prepareToken() external returns (uint256 tokenId);

    /**
     * Query the prepared tokenId.
     * @param addr The owner of prepared tokenId.
     * @return tokenId The prepared tokenId.
     */
    function ownedPrepareToken(address addr) external view returns (uint256 tokenId);

    /**
     * Post a content.
     * @param tokenId The prepared tokenId.
     * @param content  The content should be the hash on Arweave. The actual encrypted content and authorization records are stored on Arweave.
     */
    function post(uint256 tokenId, string memory content) external;

    /**
     * Whether the address is authorized to be the view of the token.
     * @param viewer The address.
     * @param tokenId The tokenId.
     * @return isViewer true--has viewer permission; false--do not have viewer permission.
     */
    function isViewerOf(address viewer, uint256 tokenId) external view returns (bool isViewer);

    /**
     * View the hash on Arweave corresponding to the token
     * @param tokenId The tokenId.
     * @return content The content.
     */
    function contentOf(uint256 tokenId) external view returns (string memory content);

}
