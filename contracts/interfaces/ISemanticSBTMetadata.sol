// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

interface ISemanticSBTMetadata is IERC721Metadata {

    /**
     * @dev Returns the Uniform Resource Identifier [URI](https://www.ietf.org/rfc/rfc3986.txt) for semantic metadata
     */
    function schemaURI() external view returns (string memory);
}

