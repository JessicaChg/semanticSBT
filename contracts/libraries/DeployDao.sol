// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Dao} from "../template/Dao.sol";


library DeployDao {

    function deployDao() external returns (address) {

        address daoContract = address(new Dao());

        return daoContract;
    }


}