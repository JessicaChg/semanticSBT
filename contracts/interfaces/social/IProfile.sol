import "../ISemanticSBT.sol";
import {SocialGraphData} from "../../libraries/SocialGraphData.sol";


interface IProfile is ISemanticSBT {

    function createProfile(SocialGraphData.Profile calldata profile) external returns (uint256);

    function setAvatar(string calldata avatar) external returns (bool);

    function follow(uint256[] calldata profileIds, bytes[] calldata datas) external returns (uint256[] memory);

    function followWithSig(SocialGraphData.FollowWithSigData calldata vars) external returns (uint256[] memory);
}