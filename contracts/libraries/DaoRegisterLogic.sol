// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Clones} from '@openzeppelin/contracts/proxy/Clones.sol';
import {IDao} from "../interfaces/social/IDao.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library DaoRegisterLogic {

    string constant  DAO_CLASS_NAME = "Dao";
    string constant  JOIN_PREDICATE = "join";
    string constant  DAO_URI_PREDICATE = "daoURI";
    string constant SYMBOL = "DSBT";
    string constant SCHEMA_URI = "ar://UTbYdbPy5Ov2bZ1ikWm_4RhMT5GJPvasE57qtSfL1oQ";

    function createDao(address daoImpl,address owner, address minter, string memory name, string memory baseURI) external returns (address){
        address daoContract = Clones.clone(daoImpl);
        _initDao(daoContract, owner, minter, name, baseURI);
        return daoContract;
    }

    function _initDao(address contractAddress, address owner, address minter, string memory name, string memory baseURI) internal {
        string[] memory classNames_ = new string[](1);
        classNames_[0] = DAO_CLASS_NAME;
        Predicate[] memory predicates_ = new Predicate[](2);
        predicates_[0] = Predicate(JOIN_PREDICATE, FieldType.SUBJECT);
        predicates_[1] = Predicate(DAO_URI_PREDICATE, FieldType.STRING);
        IDao(contractAddress).initialize(
            owner,
            minter,
            name,
            SYMBOL,
            string.concat(baseURI, "/json/"),
            SCHEMA_URI,
            classNames_,
            predicates_);
    }

}