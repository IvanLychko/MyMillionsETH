const BigNumber = web3.BigNumber;
const expect = require('chai').expect;
const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

import expectThrow from './helpers/expectThrow';

var MyMillions = artifacts.require('./MyMillions.sol');

const minute = 60;
const hour = 60 * minute;
const setNextBlockDelay = function(duration) {
    const id = Date.now()

    return new Promise((resolve, reject) => {
        web3.currentProvider.sendAsync({
            jsonrpc: '2.0',
            method: 'evm_increaseTime',
            params: [duration],
            id: id,
        }, err1 => {
            if (err1) return reject(err1)

            web3.currentProvider.sendAsync({
                jsonrpc: '2.0',
                method: 'evm_mine',
                id: id+1,
            }, (err2, res) => {
                return err2 ? reject(err2) : resolve(res)
            })
        })
    })
}


function getUser(user) {
    return {
        addr: user[0],
        balance: user[1].toNumber(),
        totalPay: user[2].toNumber(),
        wood: user[3].toNumber(),
        referralls: user[7]
    }
}

function getFactory(factory) {
    if (factory == undefined) {
        return undefined;
    }

    return {
        ftype: factory[0].toNumber(),
        level: factory[1].toNumber(),
        collected_at: factory[2].toNumber()
    }
}

function getUserWood(user) {
    return user[3].toNumber();
}

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

        let user0_info = getUser(await myMillions.users(user0_id));
        expect(user0_info.addr).to.equal(user0);

        // register user with index 2
        let user1_id = 2;
        await myMillions.register({from: user1});

        let user1_info = getUser(await myMillions.users(user1_id));
        expect(user1_info.addr).to.equal(user1);
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

        let user0_info = getUser(await myMillions.users(user0_id));
        expect(user0_info.balance).to.equal(sum);
    });

    it('buy wood factory', async function () {
        let user0_id = 1;
        // get actual price for wood factory
        let sum = (await myMillions.getPrice(0, 0)).toNumber();

        // register with buy wood factory
        await myMillions.register({from: user0});
        await myMillions.buyWoodFactory({from: user0, value: sum});

        // get factory
        let factory0_id = 0;
        let factory0_info = getFactory(await myMillions.factories(factory0_id));
        assert(factory0_info != undefined);

        expect(factory0_info.ftype).to.equal(0);
        expect(factory0_info.level).to.equal(0);
        expect(factory0_info.collected_at).to.be.within(1, Math.floor(Date.now() / 1000) * 10000);
    });

    it('buy wood factory as a part 50/50', async function () {
        let user0_id = 1;
        // get actual price for wood factory
        let sum = (await myMillions.getPrice(0, 0)).toNumber();

        // register with buy wood factory
        await myMillions.register({from: user0, value: sum * 0.5});

        // buy without sum
        await expectThrow(myMillions.buyWoodFactory({from: user0}));

        await myMillions.buyWoodFactory({from: user0, value: sum * 0.5});

        // get factory
        let factory0_id = 0;
        let factory0 = await myMillions.factories(factory0_id);
        assert(factory0 != undefined);
    });

    it('buy wood factory as a part 0/100', async function () {
        let user0_id = 1;
        // get actual price for wood factory
        let sum = (await myMillions.getPrice(0, 0)).toNumber();

        // register with buy wood factory
        await myMillions.register({from: user0, value: sum});
        await myMillions.buyWoodFactory({from: user0});

        // get factory
        let factory0_id = 0;
        let factory0 = await myMillions.factories(factory0_id);
        assert(factory0 != undefined);
    });

    it('collect wood', async function () {
        let user0_id = 1;
        // get actual price for wood factory and ppm
        let sum = (await myMillions.getPrice(0, 0)).toNumber();
        let ppm = (await myMillions.getProductsPerMinute(0, 0)).toNumber();

        // register with buy wood factory
        await myMillions.register({from: user0});
        await myMillions.buyWoodFactory({from: user0, value: sum});

        // wait first minute
        await setNextBlockDelay(minute);

        // get factory
        let factory0_id = 0;

        await myMillions.collectResources({from: user0});
        var user0_info = getUser(await myMillions.users(user0_id));
        expect(user0_info.wood).to.equal(ppm);

        var factory0_resources = (await myMillions.resourcesAtTime(factory0_id)).toNumber();
        expect(factory0_resources).to.equal(0);

        // first minute
        await setNextBlockDelay(minute);

        // wait second minute
        await myMillions.collectResources({from: user0});
        user0_info = getUser(await myMillions.users(user0_id));
        expect(user0_info.wood).to.equal(2 * ppm);

        // first minute
        await setNextBlockDelay(minute);

        // wait third minute
        await myMillions.collectResources({from: user0});
        user0_info = getUser(await myMillions.users(user0_id));
        expect(user0_info.wood).to.equal(3 * ppm);
    });

    it('level up', async function () {
        let user0_id = 1;
        // get actual price for wood factory and ppm with bonus
        let sumLevel0 = (await myMillions.getPrice(0, 0)).toNumber();
        let sumLevel1 = (await myMillions.getPrice(0, 1)).toNumber();
        let ppmLevel0 = (await myMillions.getProductsPerMinute(0, 0)).toNumber();
        let ppmLevel1 = (await myMillions.getProductsPerMinute(0, 1)).toNumber();
        let ppmBonusLevel0 = (await myMillions.getBonusPerMinute(0, 0)).toNumber();
        let ppmBonusLevel1 = (await myMillions.getBonusPerMinute(0, 1)).toNumber();

        // register with buy wood factory
        let factory0_id = 0;
        await myMillions.register({from: user0});
        await myMillions.buyWoodFactory({from: user0, value: sumLevel0});

        await setNextBlockDelay(minute);
        await myMillions.levelUp(factory0_id, {from: user0, value: 2 * sumLevel1});

        var user0_info = getUser(await myMillions.users(user0_id));
        expect(user0_info.wood).to.equal(ppmLevel0 + ppmBonusLevel0);

        // check new level
        var factory0_info = getFactory(await myMillions.factories(factory0_id));
        expect(factory0_info.level).to.equal(1);

        // check collected resources in new level
        await setNextBlockDelay(minute);
        await myMillions.collectResources({from: user0});
        user0_info = getUser(await myMillions.users(user0_id));
        expect(user0_info.wood).to.equal(ppmLevel0 + ppmBonusLevel0 + ppmLevel1 + ppmBonusLevel1);

        // check residual balance
        user0_info = getUser(await myMillions.users(user0_id));
        expect(user0_info.balance).to.equal(sumLevel1);
    });

    it('level up limited', async function () {
        let user0_id = 1;
        let levelsCount = (await myMillions.levelsCount()).toNumber()
        let factory0_id = 0;
        var totalProducts = 0;

        await myMillions.register({from: user0});

        for (var i = 0; i < levelsCount; i++) {
            // get actual price for wood factory and ppm with bonus
            let sum = (await myMillions.getPrice(0, i)).toNumber();
            let ppm = (await myMillions.getProductsPerMinute(0, i)).toNumber();
            let ppmBonus = (await myMillions.getBonusPerMinute(0, i)).toNumber();

            totalProducts += ppm + ppmBonus;

            if (i == 0) {
                await myMillions.buyWoodFactory({from: user0, value: sum});
                continue;
            }

            await setNextBlockDelay(minute);
            await myMillions.levelUp(factory0_id, {from: user0, value: sum});
        }

        await setNextBlockDelay(minute);
        await myMillions.collectResources({from: user0});

        let user0_info = getUser(await myMillions.users(user0_id));
        expect(user0_info.wood).to.equal(totalProducts);
    });

});
