# Semantic Soulbound Token
## Semantic Soulbound Token
Solidity Implementation of Semantic Soulbound Token.

## Problem Trying to solve
For now, social identity data has no common standard, then the corresponding NFT or SBT can usually only supply a single function.
In order to solve this problem, Semantic Soulbound Token take ``Resource Description Framework`` as data model for SBT metadata, that make SBT can cantain more semantic information.

## How to Use 
```
contracts/
          activity/
          core/
          interfaces/
```

## Contract
``Activity.sol`` : A example which use semantic Soubound Token contract to create a contract for an activity. \
``SemanticBaseStruct.sol`` : Data structure which used in Semantic Soulbound Token. \
``SemanticSBT.sol`` : Semantic Soulbound Token Contract. \
``ISemanticSBT.sol`` : Semantic Soulbound Token Interface. \
``ISemanticSBTSchema.sol`` : Semantic Soulbound Token Metadata Interface.


## prepare development environment, choose hardhat as the tool
- To install Hardhat
```sh
npm install --save-dev hardhat
```

## Clone the Repository
```
git clone git@github.com:JessicaChg/semanticSBT.git
cd semanticSBT
```

## compile the contracts
- install the library of this project depends on
```
npm install
```
- compile contracts
```
npx hardhat compile
```
- test contracts
```
npx hardhat test
```

## deploy 

1. deploy to local
```sh
npx hardhat node
npx hardhat run scripts/deploy.js

```

2. deploy to testnet, take the rinkeby as example

+ fill in the parameters in  hardhat.config.js
```
// Replace "INFURA PROJECT ID" with your INFURA project id
// Go to https://infura.io/, sign up, create a new App in its dashboard, and replace "KEY" with its key
const INFURA_PROJECT_ID = "INFURA INFURA PROJECT ID";

// Replace "PRIVATE KEY" with your account private key
// To export your private key from Metamask, open Metamask and go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const PRIVATE_KEY = "PRIVATE KEY";
```

+ deploy and verify
```sh
npx hardhat run scripts/deploy.js --network rinkeby

npx hardhat verify --contract contracts/core/Semantic.sol:Semantic  --network rinkeby <DEPLOYED_CONTRACT_ADDRESS>
```
