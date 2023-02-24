import "../ISemanticSBT.sol";


interface IConnectionRegister is ISemanticSBT {

    function deployConnectionContract(address to) external returns (uint256);

    function ownedConnectionContract(address owner) external view returns (address);

    function follow(address[] calldata profileIds, bytes[] calldata datas) external returns (uint256[] memory);

}