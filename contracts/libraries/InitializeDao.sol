// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {IDao} from "../interfaces/social/IDao.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library InitializeDao {

    string constant  JOIN = "join";
    string constant NAME = "Dao";
    string constant SYMBOL = "DSBT";
    string constant BASE_URI = "";
    string constant SCHEMA_URI = "ar://jCCCkgjG6Gxe46c8AfK_O7w32qylpFIvLd4_M1Zzy64";

    function initDao(address contractAddress, address owner, address minter) external returns (bool) {
        Predicate[] memory predicates_ = new Predicate[](1);
        predicates_[0] = Predicate(JOIN, FieldType.SUBJECT);
        IDao(contractAddress).initialize(owner, minter, NAME, SYMBOL, BASE_URI, SCHEMA_URI, new string[](0), predicates_);
        return true;
    }


}