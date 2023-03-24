// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Clones} from '@openzeppelin/contracts/proxy/Clones.sol';
import {IFollow} from "../interfaces/social/IFollow.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library FollowRegisterLogic {

    string constant  FOLLOWING = "following";
    string constant NAME = "Follow SBT";
    string constant SYMBOL = "SBT";
    string constant BASE_URI = "";
    string constant SCHEMA_URI = "ar://-2hCuTMqo1fz2iyzf7dbEbzoyceod5KFOyGGqNiEQWY";


    function createFollow(address followImpl,address verifyContract, address owner, address minter) external returns (address){
        address followContract = Clones.clone(followImpl);
        _initFollow(followContract, verifyContract, owner, minter);
        return followContract;
    }

    function _initFollow(address followContract, address verifyContract, address owner, address minter) internal returns (bool) {
        Predicate[] memory predicates_ = new Predicate[](1);
        predicates_[0] = Predicate(FOLLOWING, FieldType.SUBJECT);
        IFollow(followContract).initialize(owner, minter, verifyContract, NAME, SYMBOL, BASE_URI, SCHEMA_URI, new string[](0), predicates_);
        return true;
    }


}