pragma solidity >=0.8.4;

import "../ISemanticSBT.sol";

interface INameService is ISemanticSBT {

    function register(address owner, string calldata name, bool reverseRecord) external returns (uint);

    function setNameForAddr(address addr, string calldata name) external;

    function addr(string calldata name) virtual external view returns (address);

    function nameOf(address addr) external view returns (string memory);


}