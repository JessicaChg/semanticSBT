import {Connection} from "../social/Connection.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library DeployConnection {

    string constant PROFILE = "Profile";
    string constant  FOLLOWING = "following";

    function deployConnection() external returns (address) {

        address connection = address(new Connection());

        return connection;
    }


}