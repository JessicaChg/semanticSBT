// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {IFollow} from "../interfaces/social/IFollow.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library InitializeFollow {

    string constant  FOLLOWING = "following";
    string constant NAME = "Follow SBT";
    string constant SYMBOL = "SBT";
    string constant BASE_URI = "";
    string constant SCHEMA_URI = "ar://kA_KrrXX3vNQOz4CoBsjQdk9e3m5Epshvv3WvGFCe1w";

    function initFollow(address followContract, address owner, address minter) external returns (bool) {
        Predicate[] memory predicates_ = new Predicate[](1);
        predicates_[0] = Predicate(FOLLOWING, FieldType.SUBJECT);
        IFollow(followContract).initialize(owner, minter, NAME, SYMBOL, BASE_URI, SCHEMA_URI, new string[](0), predicates_);
        return true;
    }


}