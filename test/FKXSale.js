'use strict';
/* global artifacts, web3 */

const BigNumber = web3.BigNumber;

require('chai')
        .use(require('chai-as-promised'))
        .use(require('chai-bignumber')(web3.BigNumber))
        .should();

import latestTime from './helpers/latestTime';
import {increaseTimeTo, duration} from './helpers/increaseTime';
//import randomInt from './helpers/random';

const FKX = artifacts.require('FKX');
const FKXSale = artifacts.require('FKXSale');
const FKXTokenTimeLock = artifacts.require('FKXTokenTimeLock');

var token = null;

contract('FKXSale', function (accounts) {

    const baseTokens = new BigNumber(100000000000000000000); // 100 FKX
    const bonusTokens = new BigNumber(30000000000000000000); // 30 FKX
    
    before(async function () {
        this.sale = await FKXSale.new();
        this.token = FKX.at(await this.sale.token());
        this.timelock = FKXTokenTimeLock.at(await this.sale.tokenLock());
    });

    beforeEach(async function () {
        this.releaseTime = latestTime() + duration.days(120);
    });
    
    afterEach(async function () {

    });

    it('Can mint base tokens and locked bonus tokens to beneficiary', async function () {        
        await this.sale.mintBaseLockedTokens(accounts[2], baseTokens, bonusTokens, this.releaseTime).should.be.fulfilled;
        await this.timelock.release({from: accounts[2]}).should.be.rejected;
    });
    
    it('Can mint base tokens and locked bonus tokens to beneficiary only once', async function () {        
        await this.sale.mintBaseLockedTokens(accounts[2], baseTokens, bonusTokens, this.releaseTime).should.be.rejected;
        await this.timelock.release({from: accounts[2]}).should.be.rejected;
    });
    
    it('Can mint locked tokens to beneficiary', async function () {       
        await this.sale.mintLockedTokens(accounts[3], bonusTokens, this.releaseTime).should.be.fulfilled;
        await this.timelock.release({from: accounts[3]}).should.be.rejected;
    });
    
    it('Can mint locked tokens to beneficiary only once', async function () {       
        await this.sale.mintLockedTokens(accounts[3], bonusTokens, this.releaseTime).should.be.rejected;
        await this.timelock.release({from: accounts[3]}).should.be.rejected;
    });
    
    it('Can mint tokens to beneficiary', async function () {        
        await this.sale.mintTokens(accounts[4], baseTokens).should.be.fulfilled;
    });
    
    it('Owner can release all locked tokens', async function () {
        const balance = await this.token.balanceOf(this.timelock.address);
        balance.should.be.bignumber.equal(bonusTokens.mul(2)); //  2 locked (60 FKX)
        await this.sale.mintBaseLockedTokens(accounts[5], baseTokens, bonusTokens, this.releaseTime).should.be.fulfilled;
        await this.sale.mintBaseLockedTokens(accounts[6], baseTokens, bonusTokens, this.releaseTime).should.be.fulfilled;
        await this.sale.mintBaseLockedTokens(accounts[7], baseTokens, bonusTokens, this.releaseTime).should.be.fulfilled;
        const balance2 = await this.token.balanceOf(this.timelock.address);
        balance2.should.be.bignumber.equal(bonusTokens.mul(5)); // 5 locked (150 FKX)
        await this.sale.finalize().should.be.fulfilled;
        await increaseTimeTo(this.releaseTime + duration.days(121));
        await this.sale.releaseAll(0,2).should.be.fulfilled; // release 2, 3 locks left (90 FKX)
        const balance3 = await this.token.balanceOf(this.timelock.address);
        balance3.should.be.bignumber.equal(bonusTokens.mul(3));
        await this.sale.releaseAll(0,5).should.be.fulfilled; // release 3, 0 locks left (0 FKX)
        const balance4 = await this.token.balanceOf(this.timelock.address);
        balance4.should.be.bignumber.equal(0);
    });

});
