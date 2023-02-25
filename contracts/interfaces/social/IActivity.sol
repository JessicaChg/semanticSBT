import "../ISemanticSBT.sol";

interface IActivity is ISemanticSBT {


    function setActivity(string memory activity) external;

    function addWhiteList(address[] memory addressList) external;

    function participate() external;


}