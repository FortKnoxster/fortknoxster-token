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

contract('FKXTokenTimeLock', function ([_, owner, beneficiary]) {

    const amount = new BigNumber(100);

    before(async function () {
        this.token = await FKX.new({from: owner});
        await this.token.unpause({from: owner});
        this.timelock = await FKXTokenTimeLock.new(this.token.address);
        console.log("Owner: " + owner);
        console.log("Beneficiary: " + beneficiary);
        console.log("Amount: " + amount);
        console.log("FKX address: " + this.token.address);
        console.log("FKXTokenTimeLock address: " + this.timelock.address);
    });

    beforeEach(async function () {
        this.timeLockBalance = await this.token.balanceOf(this.timelock.address);
        console.log("FKXTokenTimeLock balance: " + this.timeLockBalance);
        this.releaseTime = latestTime() + duration.years(1);
//        this.timelock = await FKXTokenTimeLock.new(this.token.address, beneficiary, this.releaseTime);
        await this.token.mint(this.timelock.address, amount, {from: owner});
        await this.timelock.lockTokens(beneficiary, this.releaseTime, amount);
    });

    it('FKX tokens cannot be released before time limit', async function () {
        await this.timelock.release({from: beneficiary}).should.be.rejected;
    });

    it('FKX tokens cannot be released just before time limit', async function () {
        await increaseTimeTo(this.releaseTime - duration.seconds(3));
        await this.timelock.release({from: beneficiary}).should.be.rejected;
    });

    it('FKX tokens can be released just after limit', async function () {
        await increaseTimeTo(this.releaseTime + duration.seconds(1));
        await this.timelock.release({from: beneficiary}).should.be.fulfilled;
        const balance = await this.token.balanceOf(beneficiary);
        balance.should.be.bignumber.equal(amount);
    });

    it('FKX tokens can be released after time limit', async function () {
        await increaseTimeTo(this.releaseTime + duration.years(1));
        await this.timelock.release({from: beneficiary}).should.be.fulfilled;
        const balance = await this.token.balanceOf(beneficiary);
        balance.should.be.bignumber.equal(amount * 2);
    });

    it('FKX tokens cannot be released twice', async function () {
        await increaseTimeTo(this.releaseTime + duration.years(1));
        await this.timelock.release({from: beneficiary}).should.be.fulfilled;
        await this.timelock.release({from: beneficiary}).should.be.rejected;
        const balance = await this.token.balanceOf(beneficiary);
        balance.should.be.bignumber.equal(amount * 3);
    });

});
