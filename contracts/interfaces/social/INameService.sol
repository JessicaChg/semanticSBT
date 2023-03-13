// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../ISemanticSBT.sol";

interface INameService is ISemanticSBT {

    event SetProfile (
        address indexed owner,
        string profileHash
    );

    /**
      * To register a domain name
      * @param owner : The owner of a domain name
     * @param name : The domain name to be registered.
     * @param reverseRecord : Whether to set a record for resolving the domain name.
     * @return tokenId
     */
    function register(address owner, string calldata name, bool reverseRecord) external returns (uint tokenId);

    /**
     * To set a record for resolving the domain name, linking the name to an address.
     * @param owner : The owner of the domain name. If the address is "0", then the link is canceled.
     * @param name : The domain name.
     */
    function setNameForAddr(address owner, string calldata name) external;

    /**
     * A profileHash set for the caller
     * @param profileHash : The transaction hash from arweave.
     */
    function setProfileHash(string memory profileHash) external;

    /**
     * To resolve a domain name.
     * @param name : The domain name.
     * @return owner : The address.
     */
    function addr(string calldata name) external view returns (address owner);

    /**
     * Reverse mapping
     * @param owner : The address.
     * @return name : The domain name.
     */
    function nameOf(address owner) external view returns (string memory name);

    /**
     * To query the profileHash of an address.
     * @param owner : The address.
     * @return profileHash : The transaction hash from arweave.
     */
    function profileHash(address owner) external view returns (string memory profileHash);


}