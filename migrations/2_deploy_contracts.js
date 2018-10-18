var MyMillions = artifacts.require("./MyMillions.sol");
var Math = artifacts.require("./Math.sol");

module.exports = function (deployer) {
    deployer.deploy(Math);
    deployer.link(Math, MyMillions);
    deployer.deploy(MyMillions);
};
