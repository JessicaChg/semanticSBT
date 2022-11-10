require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');



/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1,
      },
      viaIR: true,
    },

  },
  networks: {
    rinkeby: {
      url: "<RPC URL>",
      accounts: [privateKey1, privateKey2, ...]
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "<YOUR_ETHERSCAN_API_KEY>",
  },
};
