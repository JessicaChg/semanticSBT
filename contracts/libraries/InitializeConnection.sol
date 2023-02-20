import {IConnection} from "../interfaces/social/IConnection.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library InitializeConnection {

    string constant PROFILE = "Profile";
    string constant  FOLLOWING = "following";
    string constant SYMBOL = "CONNECT";
    string constant BASE_URI = "";
    string constant SCHEMA_URI = "";

    function initConnection(address connection, uint256 profileId,string memory name) external returns (bool) {

        string[] memory classes_ = new string[](1);
        classes_[0] = PROFILE;
        Predicate[] memory predicates_ = new Predicate[](1);
        predicates_[0] = Predicate(FOLLOWING, FieldType.SUBJECT);
        IConnection(connection).initialize(profileId, msg.sender, name, SYMBOL, BASE_URI, SCHEMA_URI, classes_, predicates_);
        return true;
    }


}