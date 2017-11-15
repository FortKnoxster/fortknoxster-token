/* global artifacts, web3 */
/*
 * Test wallets
 (0) 0x261c64c4ff01d9b0808c9d9100348e5bed15897f
 (1) 0x1a50b27a196d8e3ac9785eb64a998a0e3dab3811
 (2) 0x51244e34b38f60163098d925f1625b656f5f1342
 (3) 0x51a5997561d054cb7e67c9607f0c78126b8028a8
 (4) 0x64e72aea9e8b34ff1a34dc821b8ab0aeb68fc014
 (5) 0xcc2c7abad207b81f79684d00b08b94d5756c8573
 (6) 0x90a6fac11cd9d8994790f2f4eb07c80984a8f6e3
 (7) 0xf9de9026d6ec8a8454254baf9d0bd79bd3ca7766
 (8) 0xbce55c7199de59f60e08614542eb86b457e32af7
 (9) 0x1ff9a2abc5e553a7b556029f63f34c1b1bb47b8c
 (10) 0x48073cd818bf9a53687bfe5506256563ffca093a
 (11) 0x488af1763e3d06bd8740cdc9ec2af9d270a98861
 (12) 0xbd8e82acbe2dcdee4355ab1946988396264a78e1
 (13) 0xad0e63988c9ae5d8819e6534c480ab133f37d40b
 (14) 0x1e51b7330185733f6ce8d54ebce2f37df015b5ae
 (15) 0xb9bf705c188d34ad285aa5cb0c5b8f9614d1859b
 (16) 0x4f587d2625ab608bd69ba7724405f1fc48c39e50
 (17) 0x2b4027f362c5f81dc9ef68987e6707723aad44e4
 (18) 0xfc13969d348405d3b5b2aac623d1ed729ae284a4
 (19) 0x1f4e51b07b21386f91b343b911ef61818b695f21
 */

var FKXCrowdsale = artifacts.require("./FKXCrowdsale.sol");

module.exports = function (deployer, network, accounts) {
    var startTime, endTime, rate, preRate, multiSigWallet, preSaleWallet, communityWallet, partnersWallet, companyWallet, foundersWallet;
    if (network === 'development') {
        startTime = 1511521200; // 24 Nov 2017 12:00 CET
        endTime = 1513940400;  // 22 Dec 2017 12:00 CET
        rate = 1575; // rate based on 1 ETH = 300 USD
        preRate = 1890; // rate based on 1 ETH = 300 USD
        multiSigWallet = "0x261c64c4ff01d9b0808c9d9100348e5bed15897f"; // the address that will hold the fund. Recommended to use a multisig one for security.
        preSaleWallet = "0x1a50b27a196d8e3ac9785eb64a998a0e3dab3811";
        communityWallet = "0x51244e34b38f60163098d925f1625b656f5f1342";
        partnersWallet = "0x51a5997561d054cb7e67c9607f0c78126b8028a8";
        companyWallet = "0x64e72aea9e8b34ff1a34dc821b8ab0aeb68fc014";
        foundersWallet = "0xcc2c7abad207b81f79684d00b08b94d5756c8573";
    } 
    else if (network === 'ropsten') {
        startTime = new Date().getTime() / 1000 + 60;//web3.eth.getBlock('latest').timestamp + 60; // 60 seconds after latest block
        endTime = startTime + 7200;  // 2 hours after start
        rate = 1575 * 1000; // rate based on 1 ETH = 300 USD
        preRate = 1890 * 1000; // rate based on 1 ETH = 300 USD
        multiSigWallet = web3.eth.accounts[0]; // the address that will hold the fund. Recommended to use a multisig one for security.
        preSaleWallet = web3.eth.accounts[1];
        communityWallet = web3.eth.accounts[2];
        partnersWallet = web3.eth.accounts[3];
        companyWallet = web3.eth.accounts[4];
        foundersWallet = web3.eth.accounts[5];
    }

    console.log("Deploying FKX token contracts...");

    console.log(new Date(startTime * 1000).toUTCString());
    console.log(new Date(endTime * 1000).toUTCString());
    console.log(endTime);

    console.log(rate);

    console.log(preRate);

    console.log(preSaleWallet);

    if (accounts.length) {
        for (var i = 0; i < accounts.length; i++) {
            console.log("Acount:  " + accounts[i]);
        }
    }

    //deployer.deploy(FKX);

    deployer.deploy(
            FKXCrowdsale,
            startTime,
            endTime,
            rate,
            preRate,
            multiSigWallet,
            preSaleWallet,
            communityWallet,
            partnersWallet,
            companyWallet,
            foundersWallet
            );
};