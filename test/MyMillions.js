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
    const user0 = accounts[1];
    const user1 = accounts[2];
    const user2 = accounts[3];

    const gasPrice = web3.toWei('15', 'gwei');

    beforeEach('setup contract for each test', async function () {
        myMillions = await MyMillions.new({from: owner});
    });

    it('has an owner', async function () {
        expect(await myMillions.owner()).to.equal(owner);
    });

    it('register users', async function () {
        // register user with index 1
        let user0_id = 1;
        await myMillions.register({from: user0});

        let user0_info = await myMillions.users(user0_id);
        expect(user0_info[0]).to.equal(user0);

        // register user with index 2
        let user1_id = 2;
        await myMillions.register({from: user1});

        let user1_info = await myMillions.users(user1_id);
        expect(user1_info[0]).to.equal(user1);
    });

    it('register users again', async function () {
        // register user
        let user0_id = 1;
        await myMillions.register({from: user0});

        // register user again
        await expectThrow(myMillions.register({from: user0}));
    });

    it('register users with ref id', async function () {
        // register user with index 1
        let user0_id = 1;
        await myMillions.register({from: user0});

        // register user with refId of first user
        let user1_id = 2;
        await myMillions.registerWithRefID(user0_id, {from: user1});

        // register user with refId of first user
        let user2_id = 3;
        await myMillions.registerWithRefID(user0_id, {from: user2});

        let user0_referrals = await myMillions.referralsOf({from: user0});
        expect(user0_referrals[0].toNumber()).to.equal(user1_id);
        expect(user0_referrals[1].toNumber()).to.equal(user2_id);
    });

    it('register with initial balance', async function () {
        // register user with index 1
        let sum = 10000;
        let user0_id = 1;
        await myMillions.register({from: user0, value: sum});

        let user0_balance = (await myMillions.balanceOf({from: user0})).toNumber();
        expect(user0_balance).to.equal(sum);
    });
});
