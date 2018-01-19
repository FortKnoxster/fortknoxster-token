/* global artifacts */

var FKX = artifacts.require("./FKX.sol");

var FKXSale = artifacts.require('./FKXSale.sol');

console.log("Deploying contracts...");

module.exports = function (deployer, network, accounts) {
    
    if (accounts.length) {
        for (var i = 0; i < accounts.length; i++) {
            console.log("Acount:  " + accounts[i]);
        }
    }
    
    deployer.deploy(FKX).then(function() {
        return deployer.deploy(FKXSale, FKX.address);
    });
};