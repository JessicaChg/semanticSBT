// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library SocialGraphData {
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }

    struct Profile {
        address to;
        string name;
        string avatar;
    }

    struct FollowWithSigData {
        address follower;
        uint256[] profileIds;
        bytes[] datas;
        Signature sig;
    }

}