import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../core/SemanticBaseStruct.sol";


library SemanticSBTLogic {
    using Address for address;
    using Strings for uint256;
    using Strings for uint160;

    using Strings for address;

    string  constant TURTLE_LINE_SUFFIX = " ;";
    string  constant TURTLE_END_SUFFIX = " . ";
    string  constant SOUL_CLASS_NAME = "Soul";


    string  constant ENTITY_PREFIX = ":";
    string  constant PROPERTY_PREFIX = "p:";

    string  constant CONCATENATION_CHARACTER = "_";
    string  constant BLANK_NODE_START_CHARACTER = "[";
    string  constant BLANK_NODE_END_CHARACTER = "]";
    string  constant BLANK_SPACE = " ";

    function _buildRDF(SPO memory spo, string[] storage _classNames, Predicate[] storage _predicates, string[] storage _stringO, Subject[] storage _subjects, BlankNodeO[] storage _blankNodeO) external view returns (string memory _rdf){
        _rdf = _buildS(spo, _classNames, _subjects);

        for (uint256 i = 0; i < spo.pIndex.length; i++) {
            Predicate memory p = _predicates[spo.pIndex[i]];
            if (FieldType.INT == p.fieldType) {
                _rdf = string.concat(_rdf, _buildIntRDF(spo.pIndex[i], spo.oIndex[i], _predicates));
            } else if (FieldType.STRING == p.fieldType) {
                _rdf = string.concat(_rdf, _buildStringRDF(spo.pIndex[i], spo.oIndex[i], _predicates, _stringO));
            } else if (FieldType.ADDRESS == p.fieldType) {
                _rdf = string.concat(_rdf, _buildAddressRDF(spo.pIndex[i], spo.oIndex[i], _predicates));
            } else if (FieldType.SUBJECT == p.fieldType) {
                _rdf = string.concat(_rdf, _buildSubjectRDF(spo.pIndex[i], spo.oIndex[i], _classNames, _predicates, _subjects));
            } else if (FieldType.BLANKNODE == p.fieldType) {
                _rdf = string.concat(_rdf, _buildBlankNodeRDF(spo.pIndex[i], spo.oIndex[i], _classNames, _predicates, _stringO, _subjects, _blankNodeO));
            }
            string memory suffix = i == spo.pIndex.length - 1 ? "." : ";";
            _rdf = string.concat(_rdf, suffix);
        }
    }

    function _buildS(SPO memory spo, string[] storage _classNames, Subject[] storage _subjects) internal view returns (string memory){
        string memory _className = spo.sIndex == 0 ? SOUL_CLASS_NAME : _classNames[_subjects[spo.sIndex].cIndex];
        string memory subjectValue = spo.sIndex == 0 ? address(spo.owner).toHexString() : _subjects[spo.sIndex].value;
        return string.concat(ENTITY_PREFIX, _className, CONCATENATION_CHARACTER, subjectValue, BLANK_SPACE);
    }

    function _buildIntRDF(uint256 pIndex, uint256 oIndex, Predicate[] storage _predicates) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);
        string memory o = oIndex.toString();
        return string.concat(p, BLANK_SPACE, o);
    }

    function _buildStringRDF(uint256 pIndex, uint256 oIndex, Predicate[] storage _predicates, string[] storage _stringO) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);
        string memory o = string.concat('"', _stringO[oIndex], '"');
        return string.concat(p, BLANK_SPACE, o);
    }

    function _buildAddressRDF(uint256 pIndex, uint256 oIndex, Predicate[] storage _predicates) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);
        string memory o = string.concat(ENTITY_PREFIX, SOUL_CLASS_NAME, CONCATENATION_CHARACTER, address(uint160(oIndex)).toHexString());
        return string.concat(p, BLANK_SPACE, o);
    }


    function _buildSubjectRDF(uint256 pIndex, uint256 oIndex, string[] storage _classNames, Predicate[] storage _predicates, Subject[] storage _subjects) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory _className = _classNames[_subjects[oIndex].cIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);
        string memory o = string.concat(ENTITY_PREFIX, _className, CONCATENATION_CHARACTER, _subjects[oIndex].value);
        return string.concat(p, BLANK_SPACE, o);
    }


    function _buildBlankNodeRDF(uint256 pIndex, uint256 oIndex, string[] storage _classNames, Predicate[] storage _predicates, string[] storage _stringO, Subject[] storage _subjects, BlankNodeO[] storage _blankNodeO) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);

        uint256[] memory blankPList = _blankNodeO[oIndex].pIndex;
        uint256[] memory blankOList = _blankNodeO[oIndex].oIndex;

        string memory _rdf = "";
        for (uint256 i = 0; i < blankPList.length; i++) {
            Predicate memory _p = _predicates[blankPList[i]];
            if (FieldType.INT == _p.fieldType) {
                _rdf = string.concat(_rdf, _buildIntRDF(blankPList[i], blankOList[i], _predicates));
            } else if (FieldType.STRING == _p.fieldType) {
                _rdf = string.concat(_rdf, _buildStringRDF(blankPList[i], blankOList[i], _predicates, _stringO));
            } else if (FieldType.ADDRESS == _p.fieldType) {
                _rdf = string.concat(_rdf, _buildAddressRDF(blankPList[i], blankOList[i], _predicates));
            } else if (FieldType.SUBJECT == _p.fieldType) {
                _rdf = string.concat(_rdf, _buildSubjectRDF(blankPList[i], blankOList[i], _classNames, _predicates, _subjects));
            }
            if (i < blankPList.length - 1) {
                _rdf = string.concat(_rdf, TURTLE_LINE_SUFFIX);
            }
        }

        return string.concat(p, BLANK_SPACE, BLANK_NODE_START_CHARACTER, _rdf, BLANK_NODE_END_CHARACTER);
    }


    function mint(uint256[] storage pIndex, uint256[] storage oIndex,
        IntPO[] memory intPOList, StringPO[] memory stringPOList, AddressPO[] memory addressPOList, SubjectPO[] memory subjectPOList,
        BlankNodePO[] memory blankNodePOList, Predicate[] storage _predicates, string[] storage _stringO, Subject[] storage _subjects, BlankNodeO[] storage _blankNodeO) public {

        addIntPO(pIndex, oIndex, intPOList, _predicates);
        addStringPO(pIndex, oIndex, stringPOList, _predicates, _stringO);
        addAddressPO(pIndex, oIndex, addressPOList, _predicates);
        addSubjectPO(pIndex, oIndex, subjectPOList, _predicates, _subjects);
        addBlankNodePO(pIndex, oIndex, blankNodePOList, _predicates, _stringO, _subjects, _blankNodeO);

    }


    function addIntPO(uint256[] storage pIndex, uint256[] storage oIndex, IntPO[] memory intPOList, Predicate[] storage _predicates) public {
        for (uint256 i = 0; i < intPOList.length; i++) {
            IntPO memory intPO = intPOList[i];
            _checkPredicate(intPO.pIndex, FieldType.INT, _predicates);
            pIndex.push(intPO.pIndex);
            oIndex.push(intPO.o);
        }
    }

    function addStringPO(uint256[] storage pIndex, uint256[] storage oIndex, StringPO[] memory stringPOList, Predicate[] storage _predicates, string[] storage _stringO) public {
        for (uint256 i = 0; i < stringPOList.length; i++) {
            StringPO memory stringPO = stringPOList[i];
            _checkPredicate(stringPO.pIndex, FieldType.STRING, _predicates);
            uint256 _oIndex = _stringO.length;
            _stringO.push(stringPO.o);
            pIndex.push(stringPO.pIndex);
            oIndex.push(_oIndex);
        }
    }

    function addAddressPO(uint256[] storage pIndex, uint256[] storage oIndex, AddressPO[] memory addressPOList, Predicate[] storage _predicates) public {
        for (uint256 i = 0; i < addressPOList.length; i++) {
            AddressPO memory addressPO = addressPOList[i];
            _checkPredicate(addressPO.pIndex, FieldType.ADDRESS, _predicates);
            pIndex.push(addressPO.pIndex);
            oIndex.push(uint160(addressPO.o));
        }
    }

    function addSubjectPO(uint256[] storage pIndex, uint256[] storage oIndex, SubjectPO[] memory subjectPOList, Predicate[] storage _predicates, Subject[] storage _subjects) public {
        for (uint256 i = 0; i < subjectPOList.length; i++) {
            SubjectPO memory subjectPO = subjectPOList[i];
            _checkPredicate(subjectPO.pIndex, FieldType.SUBJECT, _predicates);
            require(subjectPO.oIndex > 0 && subjectPO.oIndex < _subjects.length, "SemanticSBT: subject not exist");
            pIndex.push(subjectPO.pIndex);
            oIndex.push(subjectPO.oIndex);
        }
    }

    function addBlankNodePO(uint256[] storage pIndex, uint256[] storage oIndex, BlankNodePO[] memory blankNodePOList, Predicate[] storage _predicates, string[] storage _stringO, Subject[] storage _subjects, BlankNodeO[] storage _blankNodeO) public {
        for (uint256 i = 0; i < blankNodePOList.length; i++) {
            BlankNodePO memory blankNodePO = blankNodePOList[i];
            require(blankNodePO.pIndex < _predicates.length, "SemanticSBT: predicate not exist");

            uint256 _blankNodeOIndex = _blankNodeO.length;
            _blankNodeO.push(BlankNodeO(new uint256[](0), new uint256[](0)));
            uint256[] storage blankNodePIndex = _blankNodeO[_blankNodeOIndex].pIndex;
            uint256[] storage blankNodeOIndex = _blankNodeO[_blankNodeOIndex].oIndex;

            addIntPO(blankNodePIndex, blankNodeOIndex, blankNodePO.intO, _predicates);
            addStringPO(blankNodePIndex, blankNodeOIndex, blankNodePO.stringO, _predicates, _stringO);
            addAddressPO(blankNodePIndex, blankNodeOIndex, blankNodePO.addressO, _predicates);
            addSubjectPO(blankNodePIndex, blankNodeOIndex, blankNodePO.subjectO, _predicates, _subjects);

            pIndex.push(blankNodePO.pIndex);
            oIndex.push(_blankNodeOIndex);
        }
    }


    function _checkPredicate(uint256 pIndex, FieldType fieldType, Predicate[] storage _predicates) internal view {
        require(pIndex > 0 && pIndex < _predicates.length, "SemanticSBT: predicate not exist");
        require(_predicates[pIndex].fieldType == fieldType, "SemanticSBT: predicate type error");
    }
}