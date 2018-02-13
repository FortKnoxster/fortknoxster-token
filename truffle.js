require('dotenv').config();
require('babel-register');
require('babel-polyfill');

var HDWalletProvider = require("truffle-hdwallet-provider");

var provider = new HDWalletProvider(process.env.MNEMONIC, "https://ropsten.infura.io/${process.env.INFURA_API_KEY}");

// First account 0xd2457c13440799a1675accc86144c8a00078fec9
module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*" // Match any network id
    },
    coverage: {
      host: 'localhost',
      network_id: '*', // eslint-disable-line camelcase
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01,
    },
    rpc: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      provider: provider,
      network_id: "3",
      gas: 4700000
    },
//    ropsten: {
//      host: "localhost",
//      port: 8545,//8545,
//      network_id: "3", // Match ropsten
//      //from: "",    // Use the address we derived
//      gas: 4704624
//    },
    live: {
      network_id: 1,
      host: "localhost",
      port: 8546   // Different than the default below
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};