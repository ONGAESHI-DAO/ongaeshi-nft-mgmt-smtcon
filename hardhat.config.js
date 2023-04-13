require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
const { privateKey, alchemyPolygonNode} = require('./secrets.json');

let RPCNode = alchemyPolygonNode;
let blockNum = 41056133;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    localhost: {
      chainId: 31337,
      url: "http://127.0.0.1:8545",
    },
    // hardhat: {
    //   forking: {
    //     url: RPCNode,
    //     blockNumber: blockNum
    //   }
    // },
    testnet: {
      url: "https://rpc-mumbai.maticvigil.com/",
      chainId: 80001,
      gasPrice: 2000000000,
      accounts: [privateKey]
    }
  },
  solidity: "0.8.17",
};
