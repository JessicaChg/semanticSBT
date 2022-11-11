# relation-sbt

## compile

```sh
npm install --save-dev hardhat
npm install

npx hardhat compile

```

## deploy 

1. deploy to local
```sh
npx hardhat node
npx hardhat run scripts/deploy.js

```

2. deploy to testnet

+ fill in the parameters in  hardhat.config.js
```
const INFURA_PROJECT_ID = "";
const PRIVATE_KEY = "";
```

+ deploy and verify
```sh
npx hardhat run scripts/deploy.js rinkeby

npx hardhat verify --contract contracts/core/Semantic.sol:Semantic  --network rinkeby <DEPLOYED_CONTRACT_ADDRESS>
```