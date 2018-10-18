pragma solidity ^0.4.24;

/*
*__/\\\\____________/\\\\________________/\\\\____________/\\\\________/\\\\\\_____/\\\\\\___________________________________________________
* _\/\\\\\\________/\\\\\\_______________\/\\\\\\________/\\\\\\_______\////\\\____\////\\\___________________________________________________
*  _\/\\\//\\\____/\\\//\\\____/\\\__/\\\_\/\\\//\\\____/\\\//\\\__/\\\____\/\\\_______\/\\\_____/\\\__________________________________________
*   _\/\\\\///\\\/\\\/_\/\\\___\//\\\/\\\__\/\\\\///\\\/\\\/_\/\\\_\///_____\/\\\_______\/\\\____\///______/\\\\\_____/\\/\\\\\\____/\\\\\\\\\\_
*    _\/\\\__\///\\\/___\/\\\____\//\\\\\___\/\\\__\///\\\/___\/\\\__/\\\____\/\\\_______\/\\\_____/\\\___/\\\///\\\__\/\\\////\\\__\/\\\//////__
*     _\/\\\____\///_____\/\\\_____\//\\\____\/\\\____\///_____\/\\\_\/\\\____\/\\\_______\/\\\____\/\\\__/\\\__\//\\\_\/\\\__\//\\\_\/\\\\\\\\\\_
*      _\/\\\_____________\/\\\__/\\_/\\\_____\/\\\_____________\/\\\_\/\\\____\/\\\_______\/\\\____\/\\\_\//\\\__/\\\__\/\\\___\/\\\_\////////\\\_
*       _\/\\\_____________\/\\\_\//\\\\/______\/\\\_____________\/\\\_\/\\\__/\\\\\\\\\__/\\\\\\\\\_\/\\\__\///\\\\\/___\/\\\___\/\\\__/\\\\\\\\\\_
*        _\///______________\///___\////________\///______________\///__\///__\/////////__\/////////__\///_____\/////_____\///____\///__\//////////__
*/

import "./Math.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Factoring {

    enum FactoryType { Wood, Metal, Oil, PreciousMetal }

    mapping (uint8 => uint256) public resourcePrices;

    constructor() public {
        resourcePrices[uint8(FactoryType.Wood)]         = 0.1 ether;
        resourcePrices[uint8(FactoryType.Metal)]        = 0.2 ether;
        resourcePrices[uint8(FactoryType.Oil)]          = 0.3 ether;
        resourcePrices[uint8(FactoryType.PreciousMetal)]= 0.4 ether;
    }

    function getResourcePrice(uint8 _type) public view returns(uint256) {
        return resourcePrices[_type];
    }

}

contract Improvements is Factoring {

    mapping (uint8 => mapping (uint8 => Params)) public levelStack;
    uint8 public constant levelsCount = 7;

    struct Params {
        uint256 price;      // improvements cost
        uint256 ppm;        // products per minute
        uint256 ppmBonus;   // bonus per minute
    }

    constructor() public {
        // initial pricess
        levelStack[uint8(FactoryType.Wood)][0]          = Params(0.01 ether, 10, 0);
        levelStack[uint8(FactoryType.Metal)][0]         = Params(0.02 ether, 12, 0);
        levelStack[uint8(FactoryType.Oil)][0]           = Params(0.03 ether, 14, 0);
        levelStack[uint8(FactoryType.PreciousMetal)][0] = Params(0.04 ether, 16, 0);

        // level 1
        levelStack[uint8(FactoryType.Wood)][1]          = Params(0.05 ether, 20, 1);
        levelStack[uint8(FactoryType.Metal)][1]         = Params(0.10 ether, 22, 2);
        levelStack[uint8(FactoryType.Oil)][1]           = Params(0.15 ether, 24, 3);
        levelStack[uint8(FactoryType.PreciousMetal)][1] = Params(0.20 ether, 26, 4);

        // level 2
        levelStack[uint8(FactoryType.Wood)][2]          = Params(0.10 ether, 30, 2);
        levelStack[uint8(FactoryType.Metal)][2]         = Params(0.20 ether, 32, 3);
        levelStack[uint8(FactoryType.Oil)][2]           = Params(0.30 ether, 34, 4);
        levelStack[uint8(FactoryType.PreciousMetal)][2] = Params(0.40 ether, 36, 5);

        // level 3
        levelStack[uint8(FactoryType.Wood)][3]          = Params(0.2 ether, 40, 3);
        levelStack[uint8(FactoryType.Metal)][3]         = Params(0.4 ether, 42, 4);
        levelStack[uint8(FactoryType.Oil)][3]           = Params(0.6 ether, 44, 5);
        levelStack[uint8(FactoryType.PreciousMetal)][3] = Params(0.8 ether, 46, 6);

        // level 4
        levelStack[uint8(FactoryType.Wood)][4]          = Params(0.4 ether, 50, 4);
        levelStack[uint8(FactoryType.Metal)][4]         = Params(0.8 ether, 52, 5);
        levelStack[uint8(FactoryType.Oil)][4]           = Params(1.2 ether, 54, 6);
        levelStack[uint8(FactoryType.PreciousMetal)][4] = Params(1.6 ether, 56, 7);

        // level 5
        levelStack[uint8(FactoryType.Wood)][5]          = Params(0.8 ether, 60, 5);
        levelStack[uint8(FactoryType.Metal)][5]         = Params(1.6 ether, 62, 6);
        levelStack[uint8(FactoryType.Oil)][5]           = Params(2.4 ether, 64, 7);
        levelStack[uint8(FactoryType.PreciousMetal)][5] = Params(3.2 ether, 66, 8);

        // level 6
        levelStack[uint8(FactoryType.Wood)][6]          = Params(1.6 ether, 70, 6);
        levelStack[uint8(FactoryType.Metal)][6]         = Params(3.2 ether, 72, 7);
        levelStack[uint8(FactoryType.Oil)][6]           = Params(4.8 ether, 74, 8);
        levelStack[uint8(FactoryType.PreciousMetal)][6] = Params(6.4 ether, 76, 9);
    }

    function getPrice(FactoryType _type, uint8 _level) public view returns(uint256) {
        return levelStack[uint8(_type)][_level].price;
    }

    function getProductsPerMinute(FactoryType _type, uint8 _level) public view returns(uint256) {
        return levelStack[uint8(_type)][_level].ppm;
    }

    function getBonusPerMinute(FactoryType _type, uint8 _level) public view returns(uint256) {
        return levelStack[uint8(_type)][_level].ppmBonus;
    }
}

contract MyMillions is Ownable, Improvements {
    using SafeMath for uint256;

    event CreateUser(uint256 _index, address _address, uint256 _balance);
    event ReferralRegister(uint256 _refferalId, uint256 _userId);
    event Deposit(uint256 _userId, uint256 _value);
    event PaymentProceed(uint256 _userId, uint256 _factoryId, FactoryType _factoryType, uint256 _price);
    event CollectResources(FactoryType _type, uint256 _resources);
    event LevelUp(uint256 _factoryId, uint8 _newLevel, uint256 _userId);
    event Sell(uint256 _userId, uint8 _type, uint256 _sum);

    struct User {
        address addr;           // user address
        uint256 balance;        // balance of account
        uint256 totalPay;       // sum of all input pay
        uint256[] resources;    // collected resources
        uint256[] referrals;    // first layer referrals ids
    }

    User[] public users;
    mapping (address => uint256) public addressToUser;

    struct Factory {
        FactoryType ftype;  // factory type
        uint8 level;        // factory level
        uint256 collected_at; // timestamp updated
    }

    Factory[] public factories;
    mapping (uint256 => uint256) public factoryToUser;
    mapping (uint256 => uint256[]) public userToFactories;

    modifier onlyExistingUser() {
        require(addressToUser[msg.sender] != 0);
        _;
    }

    constructor() public payable {
        users.push(User(0x0, 0, 0, new uint256[](4), new uint256[](0)));  // for find by addressToUser map
    }

    /**
     * @dev register for only new users with min pay
     */
    function register() public payable returns(uint256) {
        require(addressToUser[msg.sender] == 0);

        uint256 index = users.push(User(msg.sender, msg.value, 0, new uint256[](4), new uint256[](0))) - 1;
        addressToUser[msg.sender] = index;

        emit CreateUser(index, msg.sender, msg.value);
        return index;
    }

    /**
     * @dev just registry by referral link
     * @param _refId the ID of the user who gets the affiliate fee
     */
    function registerWithRefID(uint256 _refId) public payable returns(uint256) {
        require(_refId < users.length);

        uint256 index = register();
        users[_refId].referrals.push(index);

        emit ReferralRegister(_refId, index);
        return index;
    }

    function deposit() public payable returns(uint256) {
        uint256 userId = addressToUser[msg.sender];
        users[userId].balance = users[userId].balance.add(msg.value);

        emit Deposit(userId, msg.value);
        return users[userId].balance;
    }


    function referralsOf() public view returns (uint256[]) {
        return users[addressToUser[msg.sender]].referrals;
    }

    function balanceOf() public view returns (uint256) {
        return users[addressToUser[msg.sender]].balance;
    }

    function resoucesOf() public view returns (uint256[]) {
        return users[addressToUser[msg.sender]].resources;
    }

    function userInfo(uint256 _userId) public view returns(address, uint256, uint256, uint256[], uint256[]) {
        User memory user = users[_userId];
        return (user.addr, user.balance, user.totalPay, user.resources, user.referrals);
    }


    function buyFactory(FactoryType _type) public payable returns (uint256) {
        uint256 userId = addressToUser[msg.sender];

        // if user not registered
        if (addressToUser[msg.sender] == 0)
            userId = register();

        _paymentProceed(userId, Factory(_type, 0, now));
    }

    function buyWoodFactory() public payable returns (uint256) {
        return buyFactory(FactoryType.Wood);
    }

    function buyMetalFactory() public payable returns (uint256) {
        return buyFactory(FactoryType.Metal);
    }

    function buyOilFactory() public payable returns (uint256) {
        return buyFactory(FactoryType.Oil);
    }

    function buyPreciousMetal() public payable returns (uint256) {
        return buyFactory(FactoryType.PreciousMetal);
    }

    function _paymentProceed(uint256 _userId, Factory _factory) private {
        User storage user = users[_userId];

        require(_checkPayment(user, _factory.ftype, _factory.level));

        uint256 price = getPrice(FactoryType.Wood, 0);
        user.balance = user.balance.add(msg.value);
        user.balance = user.balance.sub(price);
        user.totalPay = user.totalPay.add(price);

        uint256 index = factories.push(_factory) - 1;
        factoryToUser[index] = _userId;
        userToFactories[_userId].push(index);

        emit PaymentProceed(_userId, index, _factory.ftype, price);
    }

    function _checkPayment(User _user, FactoryType _type, uint8 _level) private view returns(bool) {
        uint256 totalBalance = _user.balance.add(msg.value);

        if (totalBalance < getPrice(_type, _level)) return false;

        return true;
    }


    function levelUp(uint256 _factoryId) public payable {
        Factory storage factory = factories[_factoryId];
        uint256 price = getPrice(factory.ftype, factory.level + 1);

        uint256 userId = addressToUser[msg.sender];
        User storage user = users[userId];

        require(_checkPayment(user, factory.ftype, factory.level + 1));

        // payment

        user.balance = user.balance.add(msg.value);
        user.balance = user.balance.sub(price);
        user.totalPay = user.totalPay.add(price);

        // collect

        _collectResource(factory, user);
        factory.level++;

        emit LevelUp(_factoryId, factory.level, userId);
    }


    function sellResources(uint8 _type) public returns (uint256) {
        uint256 userId = addressToUser[msg.sender];
        uint256 sum = Math.min(users[userId].resources[_type] * getResourcePrice(_type), address(this).balance);
        users[userId].resources[_type] = 0;

        msg.sender.transfer(sum);

        emit Sell(userId, _type, sum);
    }


    function worktimeAtDate(uint256 _collected_at) public view returns(uint256) {
        return (now - _collected_at) / 60;
    }

    function worktime(uint256 _factoryId) public view returns(uint256) {
        return worktimeAtDate(factories[_factoryId].collected_at);
    }


    function _resourcesAtTime(FactoryType _type, uint8 _level, uint256 _collected_at) public view returns(uint256) {
        return worktimeAtDate(_collected_at) * (getProductsPerMinute(_type, _level) + getBonusPerMinute(_type, _level));
    }

    function resourcesAtTime(uint256 _factoryId) public view returns(uint256) {
        Factory storage factory = factories[_factoryId];
        return _resourcesAtTime(factory.ftype, factory.level, factory.collected_at);
    }


    function _collectResource(Factory storage _factory, User storage _user) internal returns(uint256) {
        uint256 resources = _resourcesAtTime(_factory.ftype, _factory.level, _factory.collected_at);
        _user.resources[uint8(_factory.ftype)] = _user.resources[uint8(_factory.ftype)].add(resources);
        _factory.collected_at = now;

        emit CollectResources(_factory.ftype, resources);
        return resources;
    }

    function collectResources() public onlyExistingUser {
        uint256 index = addressToUser[msg.sender];
        User storage user = users[index];
        uint256[] storage factoriesIds = userToFactories[addressToUser[msg.sender]];

        for (uint256 i = 0; i < factoriesIds.length; i++) {
            _collectResource(factories[factoriesIds[i]], user);
        }
    }

}
