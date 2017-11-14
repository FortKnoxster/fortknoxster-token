module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      host: "localhost",
      port: 8545,//8545,
      network_id: "3", // Match ropsten
      //from: "",    // Use the address we derived
      gas: 6000000
    }
  }
};