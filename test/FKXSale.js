/* global artifacts, web3 */

const BigNumber = web3.BigNumber;

require('chai')
        .use(require('chai-as-promised'))
        .use(require('chai-bignumber')(BigNumber))
        .should();

import latestTime from './helpers/latestTime';
import {increaseTimeTo, duration} from './helpers/increaseTime';
//import randomInt from './helpers/random';

const FKX = artifacts.require('FKX');
const FKXSale = artifacts.require('FKXSale');
const FKXTokenTimeLock = artifacts.require('FKXTokenTimeLock');

var token = null;

contract('FKXSale', function (accounts) {

    const baseTokens = new BigNumber(100000000000000000000);
    const bonusTokens = new BigNumber(30000000000000000000);
    
    before(async function () {
//        this.token = await FKX.new({from: accounts[1]});
        this.sale = await FKXSale.new();        
//        await this.token.transferOwnership(this.sale.address, {from: accounts[1]});
        await this.sale.unpauseTokens();
        console.log(this.sale.address);
        console.log(this.sale.token());
        console.log(await this.sale.tokenLock());
        this.timelock = await FKXTokenTimeLock.new(await this.sale.tokenLock());
    });

    beforeEach(async function () {
        this.releaseTime = latestTime() + duration.days(120);
    });
    
    afterEach(async function () {
//        this.tokenLockBalance = await this.sale.token().balanceOf(await this.sale.tokenLock());
//        console.log("TimeLock Balance: " + this.tokenLockBalance);
    });

    it('Can mint base tokens and locked bonus tokens to beneficiary', async function () {        
        await this.sale.mintBaseLockedTokens(accounts[2], baseTokens, bonusTokens, this.releaseTime).should.be.fulfilled;
        await this.timelock.release({from: accounts[2]}).should.be.rejected;
//        await increaseTimeTo(this.releaseTime + duration.seconds(1));
//        await this.timelock.release({from: accounts[2]}).should.be.fulfilled;
    });
    
    it('Can mint locked tokens to beneficiary', async function () {       
        await this.sale.mintLockedTokens(accounts[3], bonusTokens, this.releaseTime).should.be.fulfilled;
        await this.timelock.release({from: accounts[3]}).should.be.rejected;
//        await increaseTimeTo(this.releaseTime + duration.seconds(1));
//        await this.timelock.release({from: accounts[3]}).should.be.fulfilled;
    });
    
    it('Can mint tokens to beneficiary', async function () {        
        await this.sale.mintTokens(accounts[4], baseTokens).should.be.fulfilled;
    });

});
