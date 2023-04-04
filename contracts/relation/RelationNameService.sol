// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "../core/SemanticSBTUpgradeable.sol";
import "../interfaces/social/INameService.sol";
import "../template/NameService.sol";
import {SemanticSBTLogicUpgradeable} from "../libraries/SemanticSBTLogicUpgradeable.sol";
import {NameServiceLogic} from "../libraries/NameServiceLogic.sol";


contract RelationNameService is SemanticSBTUpgradeable, NameService, PausableUpgradeable {
    using StringsUpgradeable for uint256;
    using StringsUpgradeable for address;



    function initialize(
        string memory suffix_,
        string memory name_,
        string memory symbol_,
        string memory schemaURI_,
        string[] memory classes_,
        Predicate[] memory predicates_
    ) public initializer{
        __Pausable_init_unchained();
        super.initialize(msg.sender, name_, symbol_, "", schemaURI_, classes_, predicates_);
        _minNameLength = 3;
        _maxNameLength = 20;
        suffix = suffix_;
    }


    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function addResolvedName() external onlyOwner{

    }

    function register(address owner, string calldata name, bool resolve) external override(NameService) whenNotPaused onlyMinter returns (uint tokenId) {
        return super._register(owner, name, resolve);
    }

    function register(address owner, string calldata name, uint256 deadline, bytes memory signature, bool resolve) external whenNotPaused returns (uint tokenId) {
        require(_minters[NameServiceLogic.recoverAddress(address(this), msg.sender, name, deadline, signature)], "NameService: invalid signature");
        return super._register(owner, name, resolve);
    }


    function valid(string memory name) public view override returns (bool){
        return super.valid(name);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(NameService, SemanticSBTUpgradeable)
    returns (string memory)
    {

        return super.tokenURI(tokenId);
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(NameService, SemanticSBTUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(NameService, ERC721EnumerableUpgradeable) virtual {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(NameService, ERC721Upgradeable) virtual {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }
}