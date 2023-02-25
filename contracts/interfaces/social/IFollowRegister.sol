import "../ISemanticSBT.sol";


interface IFollowRegister is ISemanticSBT {

    function deployFollowContract(address to) external returns (uint256);

    function ownedFollowContract(address owner) external view returns (address);

    function follow(address[] calldata profileIds) external returns (uint256[] memory);

}