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
        this.sale = await FKXSale.new();        
        await this.sale.unpauseTokens();
        this.timelock = await FKXTokenTimeLock.new(await this.sale.tokenLock());
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
    
    it('Can mint locked tokens to beneficiary', async function () {       
        await this.sale.mintLockedTokens(accounts[3], bonusTokens, this.releaseTime).should.be.fulfilled;
        await this.timelock.release({from: accounts[3]}).should.be.rejected;
    });
    
    it('Can mint tokens to beneficiary', async function () {        
        await this.sale.mintTokens(accounts[4], baseTokens).should.be.fulfilled;
    });

});
