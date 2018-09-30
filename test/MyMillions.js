const BigNumber = web3.BigNumber;
const expect = require('chai').expect;
const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

import expectThrow from './helpers/expectThrow';

var MyMillions = artifacts.require('./MyMillions.sol');

contract('MyMillions', function(accounts) {
    let myMillions;

    const owner = accounts[0];

    const gasPrice = web3.toWei('15', 'gwei');

    beforeEach('setup contract for each test', async function () {
        myMillions = await MyMillions.new({from: owner});
    }); 

    it('has an owner', async function () {
        expect(await myMillions.owner()).to.equal(owner);
    });
});
