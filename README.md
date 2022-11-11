# relation-sbt

## prepare development environment, choose hardhat as the tool
- To install Hardhat
```sh
npm install --save-dev hardhat
```

## Clone the Repository
```
git clone git@github.com:JessicaChg/semanticSBT.git
```

## compile the contracts
```
cd semanticSBT
npm install
npx hardhat compile
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
npx hardhat run scripts/deploy.js rinkeby

npx hardhat verify --contract contracts/core/Semantic.sol:Semantic  --network rinkeby <DEPLOYED_CONTRACT_ADDRESS>
```
