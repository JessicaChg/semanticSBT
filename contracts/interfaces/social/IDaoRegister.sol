// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../ISemanticSBT.sol";


interface IDaoRegister is ISemanticSBT {

    /**
     * To deploy the "Dao" contract
     * @param to : The address to be passed to the "Dao" contract
     * @param name : The name to be passed to the "Dao" contract
     * @return tokenId
     */
    function deployDaoContract(address to,string calldata name) external returns (uint256);


    function daoOf(uint256 tokenId) external returns (address owner, address contractAddress);
}