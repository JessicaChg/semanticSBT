// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface ISemanticSBTUpdate {

    struct RDFData {
        string subject;
        string[] predicate;
        string[] object;
    }

    function updateRDF(uint256 tokenId, RDFData memory rdfData) external;
}
