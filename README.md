# Semantic Soulbound Token
## Semantic Soulbound Token
Solidity Implementation of Semantic Soulbound Token.

## Problem Trying to solve
For now, social identity data has no common standard, then the corresponding NFT or SBT can usually only supply a single function.
In order to solve this problem, Semantic Soulbound Token take ``Resource Description Framework`` as data model for SBT metadata, that make SBT can cantain more semantic information.

## How to Use 
```
contracts/
          core/
          interfaces/
          libraries/
          template/
```

## Contract
``Activity.sol`` : A example which use semantic Soubound Token contract to create a contract for an activity. \
``NameService.sol`` : A example which use semantic Soubound Token contract to create a contract for a name service. \
``SharePrivacy.sol`` : A example which use semantic Soubound Token contract to create a contract for share privacy data. \
``SemanticBaseStruct.sol`` : Data structure which used in Semantic Soulbound Token. \
``SemanticSBT.sol`` : Semantic Soulbound Token Contract. \
``ISemanticSBT.sol`` : Semantic Soulbound Token Interface. \
``ISemanticSBTSchema.sol`` : Semantic Soulbound Token Metadata Interface.


## Clone the Repository
```
git clone git@github.com:JessicaChg/semanticSBT.git
cd semanticSBT
```

## Set environment


```shell
# require Node.js 14+
cp .env.example .env
# modify the env variable `*_PrivateKey` to your own private key

```

## Use brownie

### compile the contracts 
- 
- install the library of this project depends on
```
pip3 install eth-brownie
```
- compile contracts
```
brownie compile
```
- test contracts
```
brownie test
```

### deploy 

1. deploy to testnet, take the mumbai as example

+ add network
```shell
brownie networks list
brownie networks add polygon mumbai host=<RPC_URL> chainid=80001 explorer=<EXPORE_URL>
```

+ deploy
```sh
# libraries
brownie run brownie_scripts/libraries/deploy_semanticUpgradeLogic.py --network relation-test
brownie run brownie_scripts/libraries/deploy_nameserviceLogic.py  --network relation-test 
brownie run brownie_scripts/libraries/deploy_daoregisterLogic.py  --network relation-test 
brownie run brownie_scripts/libraries/deploy_followregisterLogic.py  --network relation-test 

# upgradeable
brownie run brownie_scripts/upgrade/deploy_proxyadmin.py --network relation-test

# social
brownie run brownie_scripts/social/deploy_nameservice.py  --network relation-test 
brownie run brownie_scripts/social/deploy_dao_register.py  --network relation-test 
brownie run brownie_scripts/social/deploy_follow_register.py  --network relation-test 
brownie run brownie_scripts/social/deploy_content.py  --network relation-test 

# relation
brownie run brownie_scripts/relation/deploy_relation_profile_nft.py  --network relation-test 
```



## use hardhat

### compile the contracts
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

### deploy

1. fill in the parameters in  hardhat.config.js
```
// Replace "INFURA PROJECT ID" with your INFURA project id
// Go to https://infura.io/, sign up, create a new App in its dashboard, and replace "KEY" with its key
const INFURA_PROJECT_ID = "INFURA INFURA PROJECT ID";

// Replace "PRIVATE KEY" with your account private key
// To export your private key from Metamask, open Metamask and go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const PRIVATE_KEY = "PRIVATE KEY";
```

2. deploy to local
```sh
npx hardhat node
npx hardhat run scripts/deploy.js

```

3. deploy to testnet, take the rinkeby as example

+ deploy and verify
```sh
npx hardhat run scripts/deploy.js --network relation-test

npx hardhat verify --contract contracts/core/Semantic.sol:Semantic  --network rinkeby <DEPLOYED_CONTRACT_ADDRESS>
```

