import "../../core/SemanticBaseStruct.sol";
import "../ISemanticSBT.sol";

interface IConnection is ISemanticSBT {


    function initialize(
        address owner,
        address minter,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory schemaURI_,
        string[] memory classes_,
        Predicate[] memory predicates_
    ) external;


    function mint(address to) external returns (uint256);

}