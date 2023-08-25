// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract RelationWithdraw is Ownable, Pausable {
    using Strings for uint256;
    using Strings for address;

    using ECDSA for bytes;
    using ECDSA for bytes32;

    mapping(address => bool) public minters;
    mapping(address => uint256) public totalWithdrawn;

    event SetMinter(address indexed addr, bool isMinter);
    event Withdraw(address indexed addr, uint256 value);

    modifier onlyMinter() {
        require(minters[msg.sender], "RelationWithdraw: must be minter");
        _;
    }

    constructor() {
        setMinter(msg.sender, true);
    }

    function setMinter(address addr, bool _isMinter) public onlyOwner {
        minters[addr] = _isMinter;
        emit SetMinter(addr, _isMinter);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    receive() external payable {}


    function withdraw(address addr) public onlyOwner {
        payable(addr).transfer(address(this).balance);
    }

    function withdraw(uint256 deadline, uint256 _withdrawAmount, uint256 _totalWithdrawnAmount, bytes memory signature) public whenNotPaused {
        require(totalWithdrawn[msg.sender] + _withdrawAmount == _totalWithdrawnAmount, "RelationWithdraw: invalid withdraw value");
        require(minters[recoverAddress(msg.sender, deadline, _withdrawAmount, _totalWithdrawnAmount, signature)], "RelationWithdraw: invalid signature");
        totalWithdrawn[msg.sender] = _totalWithdrawnAmount;
        payable(msg.sender).transfer(_withdrawAmount);
        emit Withdraw(msg.sender, _withdrawAmount);
    }


    function recoverAddress(address caller, uint256 deadline, uint256 _withdrawAmount, uint256 _totalWithdrawnAmount, bytes memory signature) internal view returns (address) {
        require(deadline > block.timestamp, "RelationWithdraw:signature expired");
        bytes32 hash = keccak256(
            abi.encodePacked(
                address(this),
                caller,
                deadline,
                _withdrawAmount,
                _totalWithdrawnAmount
            )
        ).toEthSignedMessageHash();
        return hash.recover(signature);
    }
}