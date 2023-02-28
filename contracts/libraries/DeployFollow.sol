// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Follow} from "../template/Follow.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library DeployFollow {

    function deployFollow() external returns (address) {

        address followContract = address(new Follow());

        return followContract;
    }


}