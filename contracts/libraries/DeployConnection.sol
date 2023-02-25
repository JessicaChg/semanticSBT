import {Follow} from "../template/Follow.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library DeployConnection {

    string constant PROFILE = "Profile";
    string constant  FOLLOWING = "following";

    function deployConnection() external returns (address) {

        address followContract = address(new Follow());

        return followContract;
    }


}