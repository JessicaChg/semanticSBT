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

import "../interfaces/ISemanticSBTMetadata.sol";

import "../interfaces/ISemanticSBT.sol";
import "./SemanticBaseStruct.sol";



contract SemanticSBT is Ownable, Initializable, ERC165, IERC721Enumerable, ISemanticSBT, ISemanticSBTMetadata {
    using Address for address;
    using Strings for uint256;
    using Strings for uint160;

    using Strings for address;


    string private _name;

    string private _symbol;

    uint256 private _burnCount;

    SPO[] private _tokens;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(address => bool) private _minters;

    bool private _transferable;

    Subject[] private _subjects;

    mapping(uint256 => mapping(string => uint256)) private _subjectIndex;

    string private _baseURI;

    string public schemaURI;


    mapping(string => uint256) private _classIndex;
    string[] private _classNames;

    mapping(string => uint256) private _predicateIndex;
    Predicate[] private _predicates;


    string[] _stringO;
    BlankNodeO[] _blankNodeO;


    string  constant TURTLE_LINE_SUFFIX = " ;";
    string  constant TURTLE_END_SUFFIX = " . ";
    string  constant SOUL_CLASS_NAME = "Soul";


    string  constant ENTITY_PREFIX = ":";
    string  constant PROPERTY_PREFIX = "p:";

    string  constant CONCATENATION_CHARACTER = "_";
    string  constant BLANK_NODE_START_CHARACTER = "[";
    string  constant BLANK_NODE_END_CHARACTER = "]";
    string  constant BLANK_SPACE = " ";


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
        require(keccak256(abi.encode(schemaURI_)) != keccak256(abi.encode("")), "SemanticSBT: schema URI cannot be empty");
        require(predicates_.length > 0, "SemanticSBT: predicate size can not be empty");

        _minters[minter] = true;
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
        schemaURI = schemaURI_;

        _addClass(classes_);
        _addPredicate(predicates_);
        emit EventMinterAdded(minter);
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        interfaceId == type(ISemanticSBT).interfaceId ||
        interfaceId == type(ISemanticSBTMetadata).interfaceId ||
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
        return _buildRDF(_tokens[tokenId]);
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
    public
    view
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
        require(to != owner, "ERC721: approval to current owner");

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


    function _addClass(string[] memory classList) internal {
        for (uint256 i = 0; i < classList.length; i++) {
            string memory className_ = classList[i];
            require(
                keccak256(abi.encode(className_)) != keccak256(abi.encode("")),
                "SemanticSBT: Class cannot be empty"
            );
            require(_classIndex[className_] == 0, "SemanticSBT: already added");
            _classNames.push(className_);
            _classIndex[className_] = _classNames.length - 1;
        }
    }


    function _addPredicate(Predicate[] memory predicates) internal {
        for (uint256 i = 0; i < predicates.length; i++) {
            Predicate memory predicate_ = predicates[i];
            require(
                keccak256(abi.encode(predicate_.name)) !=
                keccak256(abi.encode("")),
                "SemanticSBT: Predicate cannot be empty"
            );
            require(_predicateIndex[predicate_.name] == 0, "SemanticSBT: already added");
            _predicates.push(predicate_);
            _predicateIndex[predicate_.name] = _predicates.length - 1;
        }
    }


    function _addIntPO(uint256[] storage pIndex, uint256[] storage oIndex, IntPO[] memory intPOList) internal {
        for (uint256 i = 0; i < intPOList.length; i++) {
            IntPO memory intPO = intPOList[i];
            _checkPredicate(intPO.pIndex, FieldType.INT);
            pIndex.push(intPO.pIndex);
            oIndex.push(intPO.o);
        }
    }

    function _addStringPO(uint256[] storage pIndex, uint256[] storage oIndex, StringPO[] memory stringPOList) internal {
        for (uint256 i = 0; i < stringPOList.length; i++) {
            StringPO memory stringPO = stringPOList[i];
            _checkPredicate(stringPO.pIndex, FieldType.STRING);
            uint256 _oIndex = _stringO.length;
            _stringO.push(stringPO.o);
            pIndex.push(stringPO.pIndex);
            oIndex.push(_oIndex);
        }
    }

    function _addAddressPO(uint256[] storage pIndex, uint256[] storage oIndex, AddressPO[] memory addressPOList) internal {
        for (uint256 i = 0; i < addressPOList.length; i++) {
            AddressPO memory addressPO = addressPOList[i];
            _checkPredicate(addressPO.pIndex, FieldType.ADDRESS);
            pIndex.push(addressPO.pIndex);
            oIndex.push(uint160(addressPO.o));
        }
    }

    function _addSubjectPO(uint256[] storage pIndex, uint256[] storage oIndex, SubjectPO[] memory subjectPOList) internal {
        for (uint256 i = 0; i < subjectPOList.length; i++) {
            SubjectPO memory subjectPO = subjectPOList[i];
            _checkPredicate(subjectPO.pIndex, FieldType.SUBJECT);
            require(subjectPO.oIndex > 0 && subjectPO.oIndex < _subjects.length, "SemanticSBT: subject not exist");
            pIndex.push(subjectPO.pIndex);
            oIndex.push(subjectPO.oIndex);
        }
    }

    function _addBlankNodePO(uint256[] storage pIndex, uint256[] storage oIndex, BlankNodePO[] memory blankNodePOList) internal {
        for (uint256 i = 0; i < blankNodePOList.length; i++) {
            BlankNodePO memory blankNodePO = blankNodePOList[i];
            require(blankNodePO.pIndex < _predicates.length, "SemanticSBT: predicate not exist");

            uint256 _blankNodeOIndex = _blankNodeO.length;
            _blankNodeO.push(BlankNodeO(new uint256[](0), new uint256[](0)));
            uint256[] storage blankNodePIndex = _blankNodeO[_blankNodeOIndex].pIndex;
            uint256[] storage blankNodeOIndex = _blankNodeO[_blankNodeOIndex].oIndex;

            _addIntPO(blankNodePIndex, blankNodeOIndex, blankNodePO.intO);
            _addStringPO(blankNodePIndex, blankNodeOIndex, blankNodePO.stringO);
            _addAddressPO(blankNodePIndex, blankNodeOIndex, blankNodePO.addressO);
            _addSubjectPO(blankNodePIndex, blankNodeOIndex, blankNodePO.subjectO);

            pIndex.push(blankNodePO.pIndex);
            oIndex.push(_blankNodeOIndex);
        }
    }

    function _buildRDF(SPO memory spo) internal view returns (string memory _rdf){
        _rdf = _buildS(spo);

        for (uint256 i = 0; i < spo.pIndex.length; i++) {
            Predicate memory p = _predicates[spo.pIndex[i]];
            if (FieldType.INT == p.fieldType) {
                _rdf = string.concat(_rdf, _buildIntRDF(spo.pIndex[i], spo.oIndex[i]));
            } else if (FieldType.STRING == p.fieldType) {
                _rdf = string.concat(_rdf, _buildStringRDF(spo.pIndex[i], spo.oIndex[i]));
            } else if (FieldType.ADDRESS == p.fieldType) {
                _rdf = string.concat(_rdf, _buildAddressRDF(spo.pIndex[i], spo.oIndex[i]));
            } else if (FieldType.SUBJECT == p.fieldType) {
                _rdf = string.concat(_rdf, _buildSubjectRDF(spo.pIndex[i], spo.oIndex[i]));
            } else if (FieldType.BLANKNODE == p.fieldType) {
                _rdf = string.concat(_rdf, _buildBlankNodeRDF(spo.pIndex[i], spo.oIndex[i]));
            }
            string memory suffix = i == spo.pIndex.length - 1 ? "." : ";";
            _rdf = string.concat(_rdf, suffix);
        }
    }

    function _buildS(SPO memory spo) internal view returns (string memory){
        string memory _className = spo.sIndex == 0 ? SOUL_CLASS_NAME : _classNames[spo.sIndex];
        string memory subjectValue = spo.sIndex == 0 ? address(spo.owner).toHexString() : _subjects[spo.sIndex].value;
        return string.concat(ENTITY_PREFIX, _className, CONCATENATION_CHARACTER, subjectValue, BLANK_SPACE);
    }

    function _buildIntRDF(uint256 pIndex, uint256 oIndex) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);
        string memory o = oIndex.toString();
        return string.concat(p, BLANK_SPACE, o);
    }

    function _buildStringRDF(uint256 pIndex, uint256 oIndex) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);
        string memory o = string.concat('"', _stringO[oIndex], '"');
        return string.concat(p, BLANK_SPACE, o);
    }

    function _buildAddressRDF(uint256 pIndex, uint256 oIndex) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);
        string memory o = string.concat(ENTITY_PREFIX, SOUL_CLASS_NAME, CONCATENATION_CHARACTER, address(uint160(oIndex)).toHexString());
        return string.concat(p, BLANK_SPACE, o);
    }


    function _buildSubjectRDF(uint256 pIndex, uint256 oIndex) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory _className = _classNames[_subjects[oIndex].cIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);
        string memory o = string.concat(ENTITY_PREFIX, _className, CONCATENATION_CHARACTER, _subjects[oIndex].value);
        return string.concat(p, BLANK_SPACE, o);
    }


    function _buildBlankNodeRDF(uint256 pIndex, uint256 oIndex) internal view returns (string memory){
        Predicate memory predicate_ = _predicates[pIndex];
        string memory p = string.concat(PROPERTY_PREFIX, predicate_.name);

        uint256[] memory blankPList = _blankNodeO[oIndex].pIndex;
        uint256[] memory blankOList = _blankNodeO[oIndex].oIndex;

        string memory _rdf = "";
        for (uint256 i = 0; i < blankPList.length; i++) {
            Predicate memory _p = _predicates[blankPList[i]];
            if (FieldType.INT == _p.fieldType) {
                _rdf = string.concat(_rdf, _buildIntRDF(blankPList[i], blankOList[i]));
            } else if (FieldType.STRING == _p.fieldType) {
                _rdf = string.concat(_rdf, _buildStringRDF(blankPList[i], blankOList[i]));
            } else if (FieldType.ADDRESS == _p.fieldType) {
                _rdf = string.concat(_rdf, _buildAddressRDF(blankPList[i], blankOList[i]));
            } else if (FieldType.SUBJECT == _p.fieldType) {
                _rdf = string.concat(_rdf, _buildSubjectRDF(blankPList[i], blankOList[i]));
            }
            if (i < blankPList.length - 1) {
                _rdf = string.concat(_rdf, TURTLE_LINE_SUFFIX);
            }
        }

        return string.concat(p, BLANK_SPACE, BLANK_NODE_START_CHARACTER, _rdf, BLANK_NODE_END_CHARACTER);
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

        _addIntPO(pIndex, oIndex, intPOList);
        _addStringPO(pIndex, oIndex, stringPOList);
        _addAddressPO(pIndex, oIndex, addressPOList);
        _addSubjectPO(pIndex, oIndex, subjectPOList);
        _addBlankNodePO(pIndex, oIndex, blankNodePOList);

        require(pIndex.length > 0, "SemanticSBT: param error");

        _balances[account] += 1;


        require(
            _checkOnERC721Received(address(0), account, tokenId, ""),
            "SemanticSBT: transfer to non ERC721Receiver implementer"
        );
        emit Transfer(address(0), account, tokenId);
        emit CreateSBT(msg.sender, account, tokenId, _buildRDF(_tokens[tokenId]));
    }

    function _addEmptyToken(address account, uint256 sIndex) internal returns (uint256){
        _tokens.push(SPO(uint160(account), sIndex, new uint256[](0), new uint256[](0)));
        return _tokens.length - 1;
    }

    /* ============ External Functions ============ */


    function addSubject(string memory value, string memory className_) external onlyMinter returns (uint256 sIndex) {
        uint256 cIndex = _classIndex[className_];
        require(cIndex > 0, "SemanticSBT: param error");
        require(_subjectIndex[cIndex][value] == 0, "SemanticSBT: already added");
        sIndex = _subjects.length;
        _subjectIndex[cIndex][value] = sIndex;
        _subjects.push(Subject(value, cIndex));
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
        string memory _rdf = _buildRDF(_tokens[id]);

        _approve(address(0), id);
        _burnCount++;
        _balances[account] -= 1;
        _tokens[id].owner = 0;

        emit Transfer(account, address(0), id);
        emit RemoveSBT(msg.sender, account, id, _rdf);
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
            string memory _rdf = _buildRDF(_tokens[tokenId]);

            // Clear approvals
            _approve(address(0), tokenId);
            _tokens[tokenId].owner = 0;

            emit Transfer(account, address(0), tokenId);
            emit RemoveSBT(msg.sender, account, tokenId, _rdf);
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