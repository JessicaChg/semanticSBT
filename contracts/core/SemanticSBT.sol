// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/ISemanticSBTSchema.sol";

import "../interfaces/ISemanticSBT.sol";
import "./SemanticBaseStruct.sol";
import {SemanticSBTLogic} from "../libraries/SemanticSBTLogic.sol";


contract SemanticSBT is Ownable, Initializable, ERC165, IERC721Enumerable, ISemanticSBT, ISemanticSBTSchema, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    using Strings for uint160;

    using Strings for address;


    string private _name;

    string private _symbol;

    uint256 private _burnCount;

    SPO[] internal _tokens;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(address => bool) internal _minters;

    bool private _transferable;

    Subject[] internal _subjects;

    mapping(uint256 => mapping(string => uint256)) internal _subjectIndex;

    string private _baseURI;

    string public _schemaURI;


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


    constructor() {
        SPO memory _spo = SPO(0, 0, new uint256[](0), new uint256[](0));
        Subject memory _subject = Subject("", 0);
        _tokens.push(_spo);
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
    ) public initializer onlyOwner {
        require(keccak256(abi.encode(schemaURI_)) != keccak256(abi.encode("")), "SemanticSBT: schemaURI cannot be empty");
        require(predicates_.length > 0, "SemanticSBT: predicate can not be empty");

        _minters[minter] = true;
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
        _schemaURI = schemaURI_;

        SemanticSBTLogic.addClass(classes_, _classNames, _classIndex);
        SemanticSBTLogic.addPredicate(predicates_, _predicates, _predicateIndex);
        emit EventMinterAdded(minter);
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
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


    function baseURI() public view returns (string memory) {
        return _baseURI;
    }


    function classIndex(string memory className_) public view returns (uint256 classIndex_) {
        classIndex_ = _classIndex[className_];
    }


    function className(uint256 cIndex) public view returns (string memory name_) {
        require(cIndex > 0 && cIndex < _classNames.length, "SemanticSBT: class not exist");
        name_ = _classNames[cIndex];
    }


    function predicateIndex(string memory predicateName_) public view returns (uint256 predicateIndex_) {
        predicateIndex_ = _predicateIndex[predicateName_];
    }


    function predicate(uint256 pIndex) public view returns (string memory name_, FieldType fieldType) {
        require(pIndex > 0 && pIndex < _predicates.length, "SemanticSBT: predicate not exist");

        Predicate memory predicate_ = _predicates[pIndex];
        name_ = predicate_.name;
        fieldType = predicate_.fieldType;
    }


    function subjectIndex(string memory subjectValue, string memory className_) public view returns (uint256){
        uint256 sIndex = _subjectIndex[_classIndex[className_]][subjectValue];
        require(sIndex > 0, "SemanticSBT: not exist");
        return sIndex;
    }


    function subject(uint256 index) public view returns (string memory subjectValue, string memory className_){
        require(index > 0 && index < _subjects.length, "SemanticSBT: not exist");
        subjectValue = _subjects[index].value;
        className_ = _classNames[_subjects[index].cIndex];
    }


    function schemaURI() public view override returns (string memory) {
        return _schemaURI;
    }

    function rdfOf(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "SemanticSBT: not exist");
        return SemanticSBTLogic.buildRDF(_tokens[tokenId], _classNames, _predicates, _stringO, _subjects, _blankNodeO);
    }

    function getMinted() public view returns (uint256) {
        return _tokens.length - 1;
    }


    function totalSupply() public view override returns (uint256) {
        return getMinted() - _burnCount;
    }


    function tokenOfOwnerByIndex(address owner, uint256 index)
    public
    view
    returns (uint256)
    {
        uint256 currentIndex = 0;
        for (uint256 i = 1; i < _tokens.length; i++) {
            if (address(_tokens[i].owner) == owner) {
                if (currentIndex == index) {
                    return i;
                }
                currentIndex += 1;
            }
        }
        revert("ERC721Enumerable: owner index out of bounds");
    }


    function tokenByIndex(uint256 index)
    public
    view
    returns (uint256)
    {
        uint256 currentIndex = 0;
        for (uint256 i = 1; i < _tokens.length; i++) {
            if (_tokens[i].owner != 0) {
                if (currentIndex == index) {
                    return i;
                }
                currentIndex += 1;
            }
        }
        revert("ERC721Enumerable: token index out of bounds");
    }


    function balanceOf(address owner)
    public
    view
    override
    returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }


    function ownerOf(uint256 tokenId)
    public
    view
    override
    returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: owner query for nonexistent token"
        );
        return address(_tokens[tokenId].owner);
    }


    function isOwnerOf(address account, uint256 id)
    public
    view
    returns (bool)
    {
        address owner = ownerOf(id);
        return owner == account;
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function tokenURI(uint256 tokenId)
    external
    view
    virtual
    override
    returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
        bytes(_baseURI).length > 0
        ? string(abi.encodePacked(_baseURI, tokenId.toString(), ".json"))
        : "";
    }


    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: cannot approve to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }


    function getApproved(uint256 tokenId)
    public
    view
    override
    returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }


    function setApprovalForAll(address operator, bool approved)
    public
    override
    {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }


    function isApprovedForAll(address owner, address operator)
    public
    view
    override
    returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public onlyTransferable override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public onlyTransferable override {
        safeTransferFrom(from, to, tokenId, "");
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public onlyTransferable override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }


    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }


    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId > 0 && tokenId <= getMinted() && _tokens[tokenId].owner != 0x0;
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId)
    internal
    view
    returns (bool)
    {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
        getApproved(tokenId) == spender ||
        isApprovedForAll(owner, spender));
    }


    function _checkPredicate(uint256 pIndex, FieldType fieldType) internal view {
        require(pIndex > 0 && pIndex < _predicates.length, "SemanticSBT: predicate not exist");
        require(_predicates[pIndex].fieldType == fieldType, "SemanticSBT: predicate type error");
    }


    function _mint(uint256 tokenId, address account, IntPO[] memory intPOList, StringPO[] memory stringPOList,
        AddressPO[] memory addressPOList, SubjectPO[] memory subjectPOList,
        BlankNodePO[] memory blankNodePOList) internal {
        uint256[] storage pIndex = _tokens[tokenId].pIndex;
        uint256[] storage oIndex = _tokens[tokenId].oIndex;

        SemanticSBTLogic.mint(pIndex, oIndex, intPOList, stringPOList, addressPOList, subjectPOList, blankNodePOList, _predicates, _stringO, _subjects, _blankNodeO);
        require(pIndex.length > 0, "SemanticSBT: param error");

        _balances[account] += 1;


        require(
            _checkOnERC721Received(address(0), account, tokenId, ""),
            "SemanticSBT: transfer to non ERC721Receiver implementer"
        );
        emit Transfer(address(0), account, tokenId);
        emit CreateRDF(tokenId, SemanticSBTLogic.buildRDF(_tokens[tokenId], _classNames, _predicates, _stringO, _subjects, _blankNodeO));
    }

    function _burn(address account, uint256 tokenId) internal {
        string memory _rdf = SemanticSBTLogic.buildRDF(_tokens[tokenId], _classNames, _predicates, _stringO, _subjects, _blankNodeO);

        _approve(address(0), tokenId);
        _burnCount++;
        _balances[account] -= 1;
        _tokens[tokenId].owner = 0;

        emit Transfer(account, address(0), tokenId);
        emit RemoveRDF(tokenId, _rdf);
    }

    function _addEmptyToken(address account, uint256 sIndex) internal returns (uint256){
        _tokens.push(SPO(uint160(account), sIndex, new uint256[](0), new uint256[](0)));
        return _tokens.length - 1;
    }

    function _addSubject(string memory value, uint256 cIndex) internal returns (uint256 sIndex){
        sIndex = _subjects.length;
        _subjectIndex[cIndex][value] = sIndex;
        _subjects.push(Subject(value, cIndex));
    }

    /* ============ External Functions ============ */


    function addSubject(string memory value, string memory className_) public onlyMinter returns (uint256 sIndex) {
        uint256 cIndex = _classIndex[className_];
        require(cIndex > 0, "SemanticSBT: param error");
        require(_subjectIndex[cIndex][value] == 0, "SemanticSBT: already added");
        sIndex = _addSubject(value, cIndex);
    }

    function mint(address account, uint256 sIndex, IntPO[] memory intPOList, StringPO[] memory stringPOList,
        AddressPO[] memory addressPOList, SubjectPO[] memory subjectPOList,
        BlankNodePO[] memory blankNodePOList) external onlyMinter returns (uint256) {
        require(account != address(0), "SemanticSBT: mint to the zero address");
        require(sIndex < _subjects.length, "SemanticSBT: param error");

        uint256 tokenId = _addEmptyToken(account, sIndex);

        _mint(tokenId, account, intPOList, stringPOList, addressPOList, subjectPOList, blankNodePOList);
        return tokenId;
    }

    function burn(address account, uint256 id) external onlyMinter {
        require(
            _isApprovedOrOwner(_msgSender(), id),
            "SemanticSBT: caller is not approved or owner"
        );
        require(isOwnerOf(account, id), "SemanticSBT: not owner");
        _burn(account, id);
    }

    function burnBatch(address account, uint256[] calldata ids)
    external
    onlyMinter
    {
        _burnCount += ids.length;
        _balances[account] -= ids.length;
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 tokenId = ids[i];
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "SemanticSBT: caller is not approved or owner"
            );
            require(isOwnerOf(account, tokenId), "SemanticSBT: not owner");
            string memory _rdf = SemanticSBTLogic.buildRDF(_tokens[tokenId], _classNames, _predicates, _stringO, _subjects, _blankNodeO);

            // Clear approvals
            _approve(address(0), tokenId);
            _tokens[tokenId].owner = 0;

            emit Transfer(account, address(0), tokenId);
            emit RemoveRDF(tokenId, _rdf);
        }
    }


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            isOwnerOf(from, tokenId),
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _tokens[tokenId].owner = uint160(to);

        emit Transfer(from, to, tokenId);
    }


    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }


    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
            IERC721Receiver(to).onERC721Received(
                _msgSender(),
                from,
                tokenId,
                _data
            )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                    "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
        return true;
    }

    /* ============ Util Functions ============ */

    function setURI(string calldata newURI) external onlyOwner {
        _baseURI = newURI;
    }


    function setTransferable(bool transferable_) external onlyOwner {
        _transferable = transferable_;
    }


    function setName(string calldata newName) external onlyOwner {
        _name = newName;
    }


    function setSymbol(string calldata newSymbol) external onlyOwner {
        _symbol = newSymbol;
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