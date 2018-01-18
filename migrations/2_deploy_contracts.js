/* global artifacts */

var FKX = artifacts.require("./FKX.sol");

var FKXSale = artifacts.require('./FKXSale.sol');

console.log("FKX address: " + FKX.address);

module.exports = function (deployer, network, accounts) {
    
    deployer.deploy(FKX).then(function() {
        return deployer.deploy(FKXSale, FKX.address);
    });
    

};