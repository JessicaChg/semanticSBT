// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface ISemanticSBTOperator {


    /**
     * @dev Is this contract allow nft transfer.
     */
    function transferable() external view returns (bool);

}
