// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./SemanticSBTLogicUpgradeable.sol";


library DaoLogic {

    struct SetDaoURIWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        string daoURI;
    }

    struct SetFreeJoinWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        bool isFreeJoin;
    }

    struct AddMemberWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        address[] members;
    }

    struct JoinWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
    }

    struct RemoveWithSign {
        SemanticSBTLogicUpgradeable.Signature sig;
        address addr;
        address member;
    }

    bytes32 public constant SET_DAO_URI_WITH_SIGN_TYPE_HASH = keccak256('SetDaoURIWithSign(string daoURI,uint256 nonce,uint256 deadline)');
    bytes32 public constant SET_FREE_JOIN_WITH_SIGN_TYPE_HASH = keccak256('SetFreeJoinWithSign(bool isFreeJoin,uint256 nonce,uint256 deadline)');
    bytes32 public constant ADD_MEMBER_WITH_SIGN_TYPE_HASH = keccak256('AddMemberWithSign(address[] members,uint256 nonce,uint256 deadline)');
    bytes32 public constant JOIN_WITH_SIGN_TYPE_HASH = keccak256('JoinWithSign(uint256 nonce,uint256 deadline)');
    bytes32 public constant REMOVE_WITH_SIGN_TYPE_HASH = keccak256('RemoveWithSign(address member,uint256 nonce,uint256 deadline)');


    function setDaoURIWithSign(SetDaoURIWithSign calldata vars, string memory name, address contractAddress, uint256 nonce) external view returns (address) {
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name,
                contractAddress,
                keccak256(
                    abi.encode(
                        SET_DAO_URI_WITH_SIGN_TYPE_HASH,
                        keccak256(bytes(vars.daoURI)),
                        nonce,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        return addr;
    }

    function setFreeJoinWithSign(SetFreeJoinWithSign calldata vars, string memory name, address contractAddress, uint256 nonce) external view returns (address) {
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name,
                contractAddress,
                keccak256(
                    abi.encode(
                        SET_FREE_JOIN_WITH_SIGN_TYPE_HASH,
                        vars.isFreeJoin,
                        nonce,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        return addr;
    }


    function addMemberWithSign(AddMemberWithSign calldata vars, string memory name, address contractAddress, uint256 nonce) external view returns (address){
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name,
                contractAddress,
                keccak256(
                    abi.encode(
                        ADD_MEMBER_WITH_SIGN_TYPE_HASH,
                        keccak256(abi.encodePacked(vars.members)),
                        nonce,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        return addr;
    }

    function joinWithSign(JoinWithSign calldata vars, string memory name, address contractAddress, uint256 nonce) external view returns (address){
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name,
                contractAddress,
                keccak256(
                    abi.encode(
                        JOIN_WITH_SIGN_TYPE_HASH,
                        nonce,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        return addr;
    }

    function removeWithSign(RemoveWithSign calldata vars, string memory name, address contractAddress, uint256 nonce) external view returns (address){
        address addr;
        unchecked {
            addr = SemanticSBTLogicUpgradeable.recoverSignerFromSignature(
                name,
                contractAddress,
                keccak256(
                    abi.encode(
                        REMOVE_WITH_SIGN_TYPE_HASH,
                        vars.member,
                        nonce,
                        vars.sig.deadline
                    )
                ),
                vars.addr,
                vars.sig
            );
        }
        return addr;
    }


}