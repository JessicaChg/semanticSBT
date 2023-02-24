// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface ISemanticSBTMetadata {

    /**
     * @dev Returns the Uniform Resource Identifier [URI](https://www.ietf.org/rfc/rfc3986.txt) for semantic metadata
     */
    function schemaURI() external view returns (string memory);
}

