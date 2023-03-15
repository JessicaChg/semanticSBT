// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "../ISemanticSBT.sol";


interface IPrivacyContent is ISemanticSBT {

    /**
     * Prepare a tokenId.
     * @return tokenId
     */
    function prepareToken() external returns (uint256);

    /**
     * Query the prepared tokenId.
     * @param owner
     * @return tokenId
     */
    function ownedPrepareToken(address owner) external view returns (uint256);
    /**
     * Post a content.
     * @param tokenId
     * @param content  The content should be the hash on Arweave. The actual encrypted content and authorization records are stored on Arweave.
     */
    function post(uint256 tokenId, string memory content) external;

    /**
     * Whether the address is authorized to be the view of the token.
     * @param viewer
     * @param tokenId
     * @param isViewer
     */
    function isViewerOf(address viewer, uint256 tokenId) external view returns (bool);

    /**
     * View the hash on Arweave corresponding to the token
     * @param tokenId
     * @return content
     */
    function contentOf(uint256 tokenId) external view returns (string memory);

}
