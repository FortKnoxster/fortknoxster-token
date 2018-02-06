/* global artifacts, web3 */

const BigNumber = web3.BigNumber;

require('chai')
        .use(require('chai-as-promised'))
        .use(require('chai-bignumber')(BigNumber))
        .should();

import latestTime from './helpers/latestTime';
import {increaseTimeTo, duration} from './helpers/increaseTime';

const FKX = artifacts.require('FKX');
const FKXTokenTimeLock = artifacts.require('FKXTokenTimeLock');

var token = null;

contract('FKXTokenTimeLock', function (accounts) {

    const amount = new BigNumber(100000000000000000000);

    before(async function () {
        this.token = await FKX.new({from: accounts[1]});        
    });

    beforeEach(async function () {
        this.timelock = await FKXTokenTimeLock.new(this.token.address);
        this.timeLockBalance = await this.token.balanceOf(this.timelock.address);
        this.releaseTime = latestTime() + duration.years(1);
        await this.token.mint(this.timelock.address, amount, {from: accounts[1]});
        await this.timelock.lockTokens(accounts[2], this.releaseTime, amount);
    });
    
    afterEach(async function () {
        this.timeLockBalance = await this.token.balanceOf(this.timelock.address);
        const balance = await this.token.balanceOf(accounts[2]);
    });

    it('FKX tokens cannot be released before time limit', async function () {
        await this.timelock.release({from: accounts[2]}).should.be.rejected;
        const balance = await this.token.balanceOf(this.timelock.address);
        balance.should.be.bignumber.equal(amount);
        const beneficiaryBalance = await this.token.balanceOf(accounts[2]);
        beneficiaryBalance.should.be.bignumber.equal(0);
    });

    it('FKX tokens cannot be released just before time limit', async function () {
        await increaseTimeTo(this.releaseTime - duration.seconds(3));
        await this.timelock.release({from: accounts[2]}).should.be.rejected;
        const balance = await this.token.balanceOf(this.timelock.address);
        balance.should.be.bignumber.equal(amount);
    });

    it('FKX tokens can be released just after limit', async function () {
        await increaseTimeTo(this.releaseTime + duration.seconds(1));
        await this.timelock.release({from: accounts[2]}).should.be.fulfilled;
        const balance = await this.token.balanceOf(this.timelock.address);
        balance.should.be.bignumber.equal(0);
        const beneficiaryBalance = await this.token.balanceOf(accounts[2]);
        beneficiaryBalance.should.be.bignumber.equal(amount);
    });

    it('FKX tokens can be released after time limit', async function () {
        await increaseTimeTo(this.releaseTime + duration.years(1));
        await this.timelock.release({from: accounts[2]}).should.be.fulfilled;
        const balance = await this.token.balanceOf(this.timelock.address);
        balance.should.be.bignumber.equal(0);
    });

    it('FKX tokens cannot be released twice', async function () {
        await increaseTimeTo(this.releaseTime + duration.years(1));
        await this.timelock.release({from: accounts[2]}).should.be.fulfilled;
        await this.timelock.release({from: accounts[2]}).should.be.rejected;
        const balance = await this.token.balanceOf(this.timelock.address);
        balance.should.be.bignumber.equal(0);
    });
    
    it('FKX tokens cannot be released to other than beneficiary', async function () {
        await increaseTimeTo(this.releaseTime + duration.years(1));
        await this.timelock.release({from: accounts[3]}).should.be.rejected;
    });
    
    it('FKX tokens can be released to all beneficiaries by owner', async function () {
        await this.token.mint(this.timelock.address, amount, {from: accounts[1]});
        await this.timelock.lockTokens(accounts[3], this.releaseTime, amount);
        await this.token.mint(this.timelock.address, amount, {from: accounts[1]});
        await this.timelock.lockTokens(accounts[4], this.releaseTime, amount);
        await increaseTimeTo(this.releaseTime + duration.years(1));
        await this.timelock.releaseAll(0,3).should.be.fulfilled;
        const balance = await this.token.balanceOf(this.timelock.address);
        balance.should.be.bignumber.equal(0);
    });
    
    it('FKX tokens can be released to multiple beneficiaries by owner', async function () {
        await this.token.mint(this.timelock.address, amount, {from: accounts[1]});
        await this.timelock.lockTokens(accounts[3], this.releaseTime, amount);
        await this.token.mint(this.timelock.address, amount, {from: accounts[1]});
        await this.timelock.lockTokens(accounts[4], this.releaseTime + duration.years(2), amount);
        await this.token.mint(this.timelock.address, amount, {from: accounts[1]});
        await this.timelock.lockTokens(accounts[5], this.releaseTime, amount);
        await this.token.mint(this.timelock.address, amount, {from: accounts[1]});
        await this.timelock.lockTokens(accounts[6], this.releaseTime, amount);
        await this.token.mint(this.timelock.address, amount, {from: accounts[1]});
        await this.timelock.lockTokens(accounts[7], this.releaseTime, amount);
        await increaseTimeTo(this.releaseTime + duration.years(1));
        await this.timelock.releaseAll(0,2).should.be.fulfilled;
        await this.timelock.releaseAll(2,6).should.be.fulfilled;
        const balance = await this.token.balanceOf(this.timelock.address);
        balance.should.be.bignumber.equal(amount);
    });

});
