// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {IDao} from "../interfaces/social/IDao.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library InitializeDao {

    string constant  DAO_CLASS_NAME = "Dao";
    string constant  JOIN_PREDICATE = "join";
    string constant SYMBOL = "DSBT";
    string constant SCHEMA_URI = "ar://jCCCkgjG6Gxe46c8AfK_O7w32qylpFIvLd4_M1Zzy64";

    function initDao(address contractAddress, address owner, address minter, string memory name, string memory baseURI) external returns (bool) {
        string[] memory classNames_ = new string[](1);
        classNames_[0] = DAO_CLASS_NAME;
        Predicate[] memory predicates_ = new Predicate[](1);
        predicates_[0] = Predicate(JOIN_PREDICATE, FieldType.SUBJECT);
        IDao(contractAddress).initialize(owner, minter, name, SYMBOL, baseURI, SCHEMA_URI, classNames_, predicates_);
        return true;
    }


}