// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import '@openzeppelin/contracts/utils/Base64.sol';
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../core/SemanticBaseStruct.sol";


library FollowTokenLogic {
    using Address for address;
    using Strings for uint256;
    using Strings for uint160;
    using Strings for address;


    function getTokenURI(
        uint256 id,
        address follower,
        address owner,
        string memory rdf
    ) external pure returns (string memory) {
        string memory name = string.concat(id.toString());
        return
        string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                        abi.encodePacked(
                        '{"name":"',
                        name,
                        '","description":"RelationFollowSBT","image":"data:image/svg+xml;base64,',
                        _getSVGImageBase64Encoded(follower, owner),
                        '","attributes":[{"trait_type":"id","value":"#',
                        Strings.toString(id),
                        '"},{"trait_type":"semantic_rdf","value":"',
                        rdf,
                        '"}]}'
                    )
                )
            )
        );
    }

    function _getSVGImageBase64Encoded(address follower, address owner)
    internal
    pure
    returns (string memory)
    {
        return
        Base64.encode(
            abi.encodePacked(
                '<svg t="1678155273806" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="15104" width="800" height="200">  <path d="M853.333333 507.733333H128v42.666667h733.866667l-145.066667 145.066667 29.866667 29.866666 192-192L746.666667 341.333333l-29.866667 29.866667 136.533333 136.533333z" fill="#444444" p-id="15105"></path>',
                '<text x="-1500" y="555" fill="red" font-size="70">',
                follower.toHexString(),
                '</text>',
                '<text x="1100" y="555" fill="red" font-size="60">',
                owner.toHexString(),
                '</text> </svg>'
            )
        );
    }
}