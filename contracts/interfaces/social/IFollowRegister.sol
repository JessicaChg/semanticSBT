// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../ISemanticSBT.sol";


interface IFollowRegister is ISemanticSBT {

    function deployFollowContract(address to) external returns (uint256);

    function ownedFollowContract(address owner) external view returns (address);

}