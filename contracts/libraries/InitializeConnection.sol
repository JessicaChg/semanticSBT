import {IConnection} from "../interfaces/social/IConnection.sol";
import {Predicate, FieldType} from "../core/SemanticBaseStruct.sol";


library InitializeConnection {

    string constant  FOLLOWING = "following";
    string constant NAME = "Connection";
    string constant SYMBOL = "CONNECT";
    string constant BASE_URI = "";
    string constant SCHEMA_URI = "ar://k_dvbio3h16I82XK_O62oBBSTfMd9BnUXhY8uxfOmrk";

    function initConnection(address connection, address owner, address minter) external returns (bool) {
        Predicate[] memory predicates_ = new Predicate[](1);
        predicates_[0] = Predicate(FOLLOWING, FieldType.SUBJECT);
        IConnection(connection).initialize(owner, minter, NAME, SYMBOL, BASE_URI, SCHEMA_URI, new string[](0), predicates_);
        return true;
    }


}