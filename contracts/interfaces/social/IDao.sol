// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../core/SemanticBaseStruct.sol";
import "../ISemanticSBT.sol";

interface IDao is ISemanticSBT {


    function initialize(
        address owner,
        address minter,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory schemaURI_,
        string[] memory classes_,
        Predicate[] memory predicates_
    ) external;

    /**
      * Set the information for a DAO.
      * @param daoURI  This should be a hash on Arweave.
     */
    function setDaoURI(string memory daoURI) external;

    /**
     * Is this an open dao?
     * @param isFreeJoin true--free to join;false--closed to the public.
     */
    function isFreeJoin() external view returns (bool);

    /**
     * Add the specified address to dao in batches.
     * @param addr The specified address.
     */
    function addMember(address[] memory addr) external;

    /**
     * Join a dao.
     * @param tokenId  The tokenId for this member in the dao.
     */
    function join() external returns (uint256 tokenId);

    /**
     * Removed from a dao.
     * @param addr
     */
    function remove(address addr) external;

    /**
     * The URI for a dao.
     * @param daoURI  A resource address pointing to the data of a dao's information. It is a transaction hash on Arweave.
     */
    function daoURI() external view returns (string memory daoURI);

    /**
     * The owner of a dao.
     * @param owner The owner of a dao.
     */
    function ownerOfDao() external view returns (address owner);

    /**
      * Is a member of the dao?
      * @param addr
      * @return isMember: true--is a member of the dao;false--not a member of the dao.
     */
    function isMember(address addr) external view returns (bool isMember);

}