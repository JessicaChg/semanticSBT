import "../ISemanticSBT.sol";

interface IActivity is ISemanticSBT {


    function setActivity(string memory activity) external;

    function setWhiteList(string memory whiteListURL, bytes32 rootHash) external;

    function participate(bytes32[] calldata proof) external;


}