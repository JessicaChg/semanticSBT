// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../interfaces/ISemanticSBTSchema.sol";
import "../interfaces/ISemanticSBT.sol";
import "./SemanticBaseStruct.sol";
import {SemanticSBTLogicUpgradeable} from "../libraries/SemanticSBTLogicUpgradeable.sol";


contract SemanticSBTUpgradeableV2 is Initializable, OwnableUpgradeable, ERC165Upgradeable, IERC721MetadataUpgradeable, ERC721EnumerableUpgradeable, ISemanticSBT, ISemanticSBTSchema {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    using StringsUpgradeable for uint160;

    using StringsUpgradeable for address;

    SPO[] internal _tokens;

    mapping(address => bool) internal _minters;

    bool private _transferable;

    Subject[] internal _subjects;

    mapping(uint256 => mapping(string => uint256)) internal _subjectIndex;

    string private _tokenBaseURI;

    string public schemaURI;


    mapping(string => uint256) private _classIndex;
    string[] internal _classNames;

    mapping(string => uint256) private _predicateIndex;
    Predicate[] internal _predicates;


    string[] internal _stringO;
    BlankNodeO[] internal _blankNodeO;


    string  constant SOUL_CLASS_NAME = "Soul";


    event EventMinterAdded(address indexed newMinter);

    event EventMinterRemoved(address indexed oldMinter);



    modifier onlyMinter() {
        require(_minters[msg.sender], "SemanticSBT: must be minter");
        _;
    }

    modifier onlyTransferable() {
        require(_transferable, "SemanticSBT: must transferable");
        _;
    }


    function before_init() internal {
        __Ownable_init();
        SPO memory _spo = SPO(0, 0, new uint256[](0), new uint256[](0));
        Subject memory _subject = Subject("", 0);
        _tokens.push(_spo);
        super._mint(address(this), 0);
        _subjects.push(_subject);

        _classNames.push("");
        _classNames.push(SOUL_CLASS_NAME);
        _predicates.push(Predicate("", FieldType.INT));
    }


    function initialize(
        address minter,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory schemaURI_,
        string[] memory classes_,
        Predicate[] memory predicates_
    ) public initializer {
        require(keccak256(abi.encode(schemaURI_)) != keccak256(abi.encode("")), "SemanticSBT: schema URI cannot be empty");
        require(predicates_.length > 0, "SemanticSBT: predicate size can not be empty");
        before_init();
        _minters[minter] = true;
        _tokenBaseURI = baseURI_;
        __ERC721_init_unchained(name_, symbol_);
        schemaURI = schemaURI_;

        SemanticSBTLogicUpgradeable.addClass(classes_, _classNames, _classIndex);
        SemanticSBTLogicUpgradeable.addPredicate(predicates_, _predicates, _predicateIndex);
        emit EventMinterAdded(minter);
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC165Upgradeable, ERC721EnumerableUpgradeable) returns (bool) {
        return interfaceId == type(IERC721Upgradeable).interfaceId ||
        interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
        interfaceId == type(ISemanticSBT).interfaceId ||
        interfaceId == type(ISemanticSBTSchema).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    function minters(address account) public view returns (bool) {
        return _minters[account];
    }


    function transferable() public view returns (bool) {
        return _transferable;
    }

    function baseURI() external view returns (string memory) {
        return _tokenBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _tokenBaseURI;
    }


    function classIndex(string memory className_) public view returns (uint256 classIndex_) {
        classIndex_ = _classIndex[className_];
    }


    function className(uint256 cIndex) public view returns (string memory name_) {
        return _classNames[cIndex];
    }


    function predicateIndex(string memory predicateName_) public view returns (uint256 predicateIndex_) {
        predicateIndex_ = _predicateIndex[predicateName_];
    }


    function predicate(uint256 pIndex) public view returns (Predicate memory) {
        return _predicates[pIndex];
    }


    function subjectIndex(string memory subjectValue, string memory className_) public view returns (uint256){
        uint256 sIndex = _subjectIndex[_classIndex[className_]][subjectValue];
        require(sIndex > 0, "SemanticSBT: does not exist");
        return sIndex;
    }


    function subject(uint256 index) public view returns (string memory subjectValue, string memory className_){
        require(index > 0 && index < _subjects.length, "SemanticSBT: does not exist");
        subjectValue = _subjects[index].value;
        className_ = _classNames[_subjects[index].cIndex];
    }


    function rdfOf(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "SemanticSBT: SemanticSBT does not exist");
        return SemanticSBTLogicUpgradeable.buildRDF(_tokens[tokenId], _classNames, _predicates, _stringO, _subjects, _blankNodeO);
    }


    function _mint(uint256 tokenId, address account, IntPO[] memory intPOList, StringPO[] memory stringPOList,
        AddressPO[] memory addressPOList, SubjectPO[] memory subjectPOList,
        BlankNodePO[] memory blankNodePOList) internal {
        uint256[] storage pIndex = _tokens[tokenId].pIndex;
        uint256[] storage oIndex = _tokens[tokenId].oIndex;

        SemanticSBTLogicUpgradeable.mint(pIndex, oIndex, intPOList, stringPOList, addressPOList, subjectPOList, blankNodePOList, _predicates, _stringO, _subjects, _blankNodeO);
        require(pIndex.length > 0, "SemanticSBT: mint without predicate");

        super._mint(account, tokenId);
        emit CreateRDF(tokenId, SemanticSBTLogicUpgradeable.buildRDF(_tokens[tokenId], _classNames, _predicates, _stringO, _subjects, _blankNodeO));
    }


    function _addEmptyToken(address account, uint256 sIndex) internal returns (uint256){
        _tokens.push(SPO(uint160(account), sIndex, new uint256[](0), new uint256[](0)));
        return _tokens.length - 1;
    }

    /* ============ External Functions ============ */


    function addSubject(string memory value, string memory className_) public onlyMinter returns (uint256 sIndex) {
        return SemanticSBTLogicUpgradeable.addSubject(value, className_, _subjects, _subjectIndex, _classIndex);
    }

    function mint(address account, uint256 sIndex, IntPO[] memory intPOList, StringPO[] memory stringPOList,
        AddressPO[] memory addressPOList, SubjectPO[] memory subjectPOList,
        BlankNodePO[] memory blankNodePOList) external onlyMinter returns (uint256) {
        require(sIndex < _subjects.length, "SemanticSBT: param sIndex error");

        uint256 tokenId = _addEmptyToken(account, sIndex);

        _mint(tokenId, account, intPOList, stringPOList, addressPOList, subjectPOList, blankNodePOList);
        return tokenId;
    }

    function burn(address account, uint256 id) external onlyMinter {
        string memory _rdf = SemanticSBTLogicUpgradeable.buildRDF(_tokens[id], _classNames, _predicates, _stringO, _subjects, _blankNodeO);

        _tokens[id].owner = 0;
        super._burn(id);

        emit RemoveRDF(id, _rdf);
    }


    /* ============ Util Functions ============ */

    function setURI(string calldata newURI) external onlyOwner {
        _tokenBaseURI = newURI;
    }


    function setTransferable(bool transferable_) external onlyOwner {
        _transferable = transferable_;
    }


    function addMinter(address minter) external onlyOwner {
        require(minter != address(0), "SemanticSBT: minter must not be null address");
        require(!_minters[minter], "SemanticSBT: minter already added");
        _minters[minter] = true;
        emit EventMinterAdded(minter);
    }


    function removeMinter(address minter) external onlyOwner {
        require(_minters[minter], "SemanticSBT: minter does not exist");
        delete _minters[minter];
        emit EventMinterRemoved(minter);
    }

}