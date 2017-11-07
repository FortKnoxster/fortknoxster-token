var FortKnoxsterToken = artifacts.require("./FortKnoxsterToken.sol");
//var FortKnoxsterCrowdsale = artifacts.require("./FortKnoxsterCrowdsale.sol");

module.exports = function(deployer, network, accounts) {
  const startTime = web3.eth.getBlock('latest').timestamp + 60; //
  const endTime = startTime + 172800;  // 
  const rate = new web3.BigNumber(400); // rate
  const goal = 0; // In wei
  const cap = 10000000000000000000; // In wei, 10000000000000000000 is 20 ether
  const wallet = web3.eth.accounts[0]; // the address that will hold the fund. Recommended to use a multisig one for security.

  console.log("Deploying FortKnoxsterToken contract...");

  deployer.deploy(FortKnoxsterToken);

  //deployer.deploy(FortKnoxsterCrowdsale, startTime, endTime, rate, goal, cap, wallet);
};