var MyMillions = artifacts.require("./MyMillions.sol");

module.exports = function (deployer) {
	deployer.deploy(MyMillions);
};