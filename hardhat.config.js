require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require("solidity-docgen");
const { privateKey, alchemyPolygonNode} = require('./secrets.json');

let RPCNode = alchemyPolygonNode;
let blockNum = 50167500;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    localhost: {
      chainId: 31337,
      url: "http://127.0.0.1:8545",
      accounts: [privateKey]
    },
    hardhat: {
      forking: {
        url: RPCNode,
        blockNumber: blockNum
      }
    },
    testnet: {
      url: "https://rpc-mumbai.maticvigil.com/",
      chainId: 80001,
      gasPrice: 2000000000,
      accounts: [privateKey]
    },
    mainnet: {
      url: "https://polygon-rpc.com/",
      chainId: 137,
      gasPrice: 150000000000,
      accounts: [privateKey]
    }
  },
  solidity: {
    version: "0.8.19",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200
      }
    },
  },
  gasReporter: {
    enabled: true,
    currency: 'JPY',
    token: 'MATIC',
    gasPrice: 137,
    // coinmarketcap: "API KEY"
  },
  docgen: {
    pages: 'files'
  }
};
