// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "../ISemanticSBT.sol";

interface IContent is ISemanticSBT {

    /**
     * Prepare a tokenId.
     * @return tokenId The tokenId.
     */
    function prepareToken() external returns (uint256 tokenId);

    /**
     * Query the prepared tokenId.
     * @param owner The address.
     * @return tokenId The tokenId.
     */
    function ownedPrepareToken(address owner) external view returns (uint256 tokenId);

    /**
     * Post a content.
     * @param tokenId The tokenId.
     * @param content  The content should be the hash on arweave. The actual encrypted content and authorization records are stored on arweave.
     */
    function post(uint256 tokenId, string memory content) external;

    /**
     * View the hash on arweave corresponding to the token.
     * @param tokenId The tokenId.
     * @return content The content.
     */
    function contentOf(uint256 tokenId) external view returns (string memory content);
}
