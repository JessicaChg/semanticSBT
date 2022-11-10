// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Required interface of an ISemanticData compliant contract.
 */
interface ISemanticSBT is IERC721 {


    event CreateSBT(
        address indexed operator,
        address indexed owner,
        uint256 indexed tokenId,
        string rdf
    );

    event RemoveSBT(
        address indexed operator,
        address indexed owner,
        uint256 indexed tokenId,
        string rdf
    );



    /**
     * @dev Returns the RDF for `tokenId` token.
     * @param tokenId The token Id
     */
    function rdfOf(uint256 tokenId) external view returns (string memory);
}
