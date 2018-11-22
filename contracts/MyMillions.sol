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

contract ReferralsSystem {

    struct ReferralGroup {
        uint256 minSum;
        uint256 maxSum;
        uint16[] percents;
    }

    uint256 public constant minSumReferral = 0.01 ether;
    uint256 public constant referralLevelsGroups = 3;
    uint256 public constant referralLevelsCount = 5;
    ReferralGroup[] public referralGroups;

    constructor() public {
        ReferralGroup memory refGroupFirsty = ReferralGroup(minSumReferral, 10 ether - 1 wei, new uint16[](referralLevelsCount));
        refGroupFirsty.percents[0] = 300;   // 3%
        refGroupFirsty.percents[1] = 75;    // 0.75%
        refGroupFirsty.percents[2] = 60;    // 0.6%
        refGroupFirsty.percents[3] = 40;    // 0.4%
        refGroupFirsty.percents[4] = 25;    // 0.25%
        referralGroups.push(refGroupFirsty);

        ReferralGroup memory refGroupLoyalty = ReferralGroup(10 ether, 50 ether - 1 wei, new uint16[](referralLevelsCount));
        refGroupLoyalty.percents[0] = 500;  // 5%
        refGroupLoyalty.percents[1] = 200;  // 2%
        refGroupLoyalty.percents[2] = 150;  // 1.5%
        refGroupLoyalty.percents[3] = 100;  // 1%
        refGroupLoyalty.percents[4] = 50;   // 0.5%
        referralGroups.push(refGroupLoyalty);

        ReferralGroup memory refGroupUltraPremium = ReferralGroup(50 ether, 2**256 - 1, new uint16[](referralLevelsCount));
        refGroupUltraPremium.percents[0] = 700; // 7%
        refGroupUltraPremium.percents[1] = 300; // 3%
        refGroupUltraPremium.percents[2] = 250; // 2.5%
        refGroupUltraPremium.percents[3] = 150; // 1.5%
        refGroupUltraPremium.percents[4] = 100; // 1%
        referralGroups.push(refGroupUltraPremium);
    }

    function getReferralPercents(uint256 _sum) public view returns(uint16[]) {
        for (uint i = 0; i < referralLevelsGroups; i++) {
            ReferralGroup memory group = referralGroups[i];
            if (_sum >= group.minSum && _sum <= group.maxSum) return group.percents;
        }
    }

    function getReferralPercentsByIndex(uint256 _index) public view returns(uint16[]) {
        return referralGroups[_index].percents;
    }

}

contract LeaderSystem {
    using SafeMath for uint256;

    event NewLeader(uint256 _indexTable, address _addr, uint256 _index, uint256 _sum);
    event LeadersClear(uint256 _indexTable);

    uint8 public constant leadersCount = 7;
    mapping (uint8 => uint256) public leaderBonuses;

    struct LeadersTable {
        uint256 timestampEnd;              // timestamp of closing table
        uint256 duration;                   // duration compute
        uint256 minSum;                     // min sum of leaders
        address[] leaders;                  // leaders array
        mapping (address => uint256) users; // sum all users
    }

    LeadersTable[] public leaders;

    constructor() public {
        leaderBonuses[0] = 10;  // 10%
        leaderBonuses[1] = 7;   // 7%
        leaderBonuses[2] = 5;   // 5%
        leaderBonuses[3] = 3;   // 3%
        leaderBonuses[4] = 1;   // 1%
        leaderBonuses[5] = 0;   // 0%
        leaderBonuses[6] = 0;   // 0%

        leaders.push(LeadersTable(now + 86400, 86400, 0, new address[](leadersCount)));
        leaders.push(LeadersTable(now + 604800, 604800, 0, new address[](leadersCount)));
        leaders.push(LeadersTable(now + 77760000, 77760000, 0, new address[](leadersCount)));
        leaders.push(LeadersTable(now + 31536000, 31536000, 0, new address[](leadersCount)));
    }

    function _clearLeadersTable(uint256 _indexTable) internal {
        LeadersTable storage _leader = leaders[_indexTable];
        leaders[_indexTable] = LeadersTable(_leader.timestampEnd + _leader.duration, _leader.duration, 0, new address[](leadersCount));

        emit LeadersClear(_indexTable);
    }

    function _updateLeaders(address _addr, uint256 _value) internal returns(uint256) {
        for (uint i = 0; i < leaders.length; i++) {
            if (now > leaders[i].timestampEnd) _clearLeadersTable(i);

            LeadersTable storage leader = leaders[i];
            address[] storage leadersUser = leader.leaders;

            uint256 newSum = leader.users[_addr].add(_value);
            leader.users[_addr] = newSum;

            if (newSum < leader.minSum) continue;

            uint256 newLength = Math.min(leadersUser.length + 1, leadersCount);
            address[] memory result = new address[](newLength);
            bool replaced = false;

            for (uint j = 0; j < newLength; j++) {
                if (replaced == false) {
                    if (newSum > leader.users[leadersUser[j]]) {
                        result[j] = _addr;
                        replaced = true;

                        emit NewLeader(i, _addr, j, newSum);
                    }
                    else result[j] = leadersUser[j];
                }
                else result[j] = leadersUser[j - 1];
            }

            leader.leaders = result;
        }
    }

    function getLeadersTableInfo(uint256 _indexTable) public view returns(uint256, uint256, uint256) {
        return (leaders[_indexTable].timestampEnd, leaders[_indexTable].duration, leaders[_indexTable].minSum);
    }

    function getLeaders(uint256 _indexTable) public view returns(address[], uint256[]) {
        LeadersTable storage leader = leaders[_indexTable];
        uint256[] memory balances = new uint256[](leader.leaders.length);

        for (uint i = 0; i < leader.leaders.length; i++) {
            balances[i] = leader.users[leader.leaders[i]];
        }

        return (leader.leaders, balances);
    }

}

/// @title Smart-contract of MyMillions ecosystem
/// @author Shagaleev Alexey
contract MyMillions is Ownable, Improvements, ReferralsSystem, LeaderSystem {
    using SafeMath for uint256;

    event CreateUser(uint256 _index, address _address, uint256 _balance);
    event ReferralRegister(uint256 _refferalId, uint256 _userId);
    event ReferrerDistribute(uint256 _userId, uint256 _referrerId, uint256 _sum);
    event Deposit(uint256 _userId, uint256 _value);
    event PaymentProceed(uint256 _userId, uint256 _factoryId, FactoryType _factoryType, uint256 _price);
    event CollectResources(FactoryType _type, uint256 _resources);
    event LevelUp(uint256 _factoryId, uint8 _newLevel, uint256 _userId);
    event Sell(uint256 _userId, uint8 _type, uint256 _sum);

    struct User {
        address addr;                                   // user address
        uint256 balance;                                // balance of account
        uint256 totalPay;                               // sum of all input pay
        uint256[] resources;                            // collected resources
        uint256[] referrersByLevel;                     // referrers user ids
        mapping (uint8 => uint256[]) referralsByLevel;  // all referrals user ids
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
        users.push(User(0x0, 0, 0, new uint256[](4), new uint256[](referralLevelsCount)));  // for find by addressToUser map
    }

    // @dev register for only new users with min pay
    /// @return id of new user
    function register() public payable returns(uint256) {
        require(addressToUser[msg.sender] == 0);

        uint256 index = users.push(User(msg.sender, msg.value, 0, new uint256[](4), new uint256[](referralLevelsCount))) - 1;
        addressToUser[msg.sender] = index;

        emit CreateUser(index, msg.sender, msg.value);
        return index;
    }


    /// @notice just registry by referral link
    /// @param _refId the ID of the user who gets the affiliate fee
    /// @return id of new user
    function registerWithRefID(uint256 _refId) public payable returns(uint256) {
        require(_refId < users.length);

        uint256 index = register();
        _updateReferrals(index, _refId);

        emit ReferralRegister(_refId, index);
        return index;
    }

    /// @notice update referrersByLevel and referralsByLevel of new user
    /// @param _newUserId the ID of the new user
    /// @param _refUserId the ID of the user who gets the affiliate fee
    function _updateReferrals(uint256 _newUserId, uint256 _refUserId) private {
        if (_newUserId == _refUserId) return;
        users[_newUserId].referrersByLevel[0] = _refUserId;

        for (uint i = 1; i < referralLevelsCount; i++) {
            uint256 _refId = users[_refUserId].referrersByLevel[i - 1];
            users[_newUserId].referrersByLevel[i] = _refId;
            users[_refId].referralsByLevel[uint8(i)].push(_newUserId);
        }

        users[_refUserId].referralsByLevel[0].push(_newUserId);
    }

    /// @notice distribute value of tx to referrers of user
    /// @param _userId the ID of the user who gets the affiliate fee
    /// @param _sum value of ethereum for distribute to referrers of user
    function _distributeReferrers(uint256 _userId, uint256 _sum) private {
        if (users[_userId].totalPay < minSumReferral) return;

        uint256[] memory referrers = users[_userId].referrersByLevel;
        uint16[] memory percents = getReferralPercents(users[_userId].totalPay);

        for (uint i = 0; i < referralLevelsCount; i++) {
            if (referrers[i] == 0) break;

            uint256 value = _sum * percents[i] / 10000;
            users[referrers[i]].balance = users[referrers[i]].balance.add(value);

            emit ReferrerDistribute(_userId, referrers[i], value);
        }
    }

    /// @notice deposit ethereum for user
    /// @return balance value of user
    function deposit() public payable returns(uint256) {
        uint256 userId = addressToUser[msg.sender];
        users[userId].balance = users[userId].balance.add(msg.value);

        // distribute
        _distributeInvestment(msg.value);
        _updateLeaders(msg.sender, msg.value);

        emit Deposit(userId, msg.value);
        return users[userId].balance;
    }

    /// @notice getter for balance of user
    /// @return balance value of user
    function balanceOf() public view returns (uint256) {
        return users[addressToUser[msg.sender]].balance;
    }

    /// @notice getter for resources of user
    /// @return resources value of user
    function resoucesOf() public view returns (uint256[]) {
        return users[addressToUser[msg.sender]].resources;
    }

    /// @notice getter for referrers of user
    /// @return array of referrers id
    function referrersOf() public view returns (uint256[]) {
        return users[addressToUser[msg.sender]].referrersByLevel;
    }

    /// @notice getter for referrals of user by level
    /// @param _level level of referrals user needed
    /// @return array of referrals id
    function referralsOf(uint8 _level) public view returns (uint256[]) {
        return users[addressToUser[msg.sender]].referralsByLevel[uint8(_level)];
    }

    /// @notice getter for extended information of user
    /// @param _userId id of user needed
    /// @return address of user
    /// @return balance of user
    /// @return totalPay of user
    /// @return array of resources user
    /// @return array of referrers id user
    function userInfo(uint256 _userId) public view returns(address, uint256, uint256, uint256[], uint256[]) {
        User memory user = users[_userId];
        return (user.addr, user.balance, user.totalPay, user.resources, user.referrersByLevel);
    }

    /// @notice mechanics of buying any factory
    /// @param _type type of factory needed
    /// @return id of new factory
    function buyFactory(FactoryType _type) public payable returns (uint256) {
        uint256 userId = addressToUser[msg.sender];

        // if user not registered
        if (addressToUser[msg.sender] == 0)
            userId = register();

        return _paymentProceed(userId, Factory(_type, 0, now));
    }

    /// @notice get factories of user
    /// @param _user_id id of user
    /// @return array of id facotry
    function getFactories(uint256 _user_id) public view returns (uint256[]) {
        return userToFactories[_user_id];
    }

    /// @notice buy wood factory
    /// @dev wrapper over buyFactory for FactoryType.Wood
    /// @return id of new factory
    function buyWoodFactory() public payable returns (uint256) {
        return buyFactory(FactoryType.Wood);
    }

    /// @notice buy wood factory
    /// @dev wrapper over buyFactory for FactoryType.Metal
    /// @return id of new factory
    function buyMetalFactory() public payable returns (uint256) {
        return buyFactory(FactoryType.Metal);
    }

    /// @notice buy wood factory
    /// @dev wrapper over buyFactory for FactoryType.Oil
    /// @return id of new factory
    function buyOilFactory() public payable returns (uint256) {
        return buyFactory(FactoryType.Oil);
    }

    /// @notice buy wood factory
    /// @dev wrapper over buyFactory for FactoryType.PreciousMetal
    /// @return id of new factory
    function buyPreciousMetal() public payable returns (uint256) {
        return buyFactory(FactoryType.PreciousMetal);
    }

    /// @notice distribute investment when user buy anything
    /// @param _value value of investment
    function _distributeInvestment(uint256 _value) private {
        developers.transfer(msg.value * developersPercent / 100);
    }

    /// @notice function of proceed payment
    /// @dev for only buy new factory
    /// @return id of new factory
    function _paymentProceed(uint256 _userId, Factory _factory) private returns(uint256) {
        User storage user = users[_userId];

        require(_checkPayment(user, _factory.ftype, _factory.level));

        uint256 price = getPrice(FactoryType.Wood, 0);
        user.balance = user.balance.add(msg.value);
        user.balance = user.balance.sub(price);
        user.totalPay = user.totalPay.add(price);

        uint256 index = factories.push(_factory) - 1;
        factoryToUser[index] = _userId;
        userToFactories[_userId].push(index);

        // distribute
        _distributeInvestment(msg.value);
        _distributeReferrers(_userId, price);
        _updateLeaders(msg.sender, msg.value);

        emit PaymentProceed(_userId, index, _factory.ftype, price);
        return index;
    }

    /// @notice check available investment
    /// @return true if user does enough balance for investment
    function _checkPayment(User _user, FactoryType _type, uint8 _level) private view returns(bool) {
        uint256 totalBalance = _user.balance.add(msg.value);

        if (totalBalance < getPrice(_type, _level)) return false;

        return true;
    }

    /// @notice level up for factory
    /// @param _factoryId id of factory
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

    /// @notice sell resources of user with type
    /// @param _type type of resources
    /// @return sum of sell
    function sellResources(uint8 _type) public returns (uint256) {
        uint256 userId = addressToUser[msg.sender];
        uint256 sum = Math.min(users[userId].resources[_type] * getResourcePrice(_type), address(this).balance);
        users[userId].resources[_type] = 0;

        msg.sender.transfer(sum);

        emit Sell(userId, _type, sum);
        return sum;
    }

    /// @notice function for compute worktime factory
    /// @param _collected_at timestamp of start
    /// @return duration minutes
    function worktimeAtDate(uint256 _collected_at) public view returns(uint256) {
        return (now - _collected_at) / 60;
    }

    /// @notice function for compute duration work factory
    /// @param _factoryId id of factory
    /// @return timestamp of duration
    function worktime(uint256 _factoryId) public view returns(uint256) {
        return worktimeAtDate(factories[_factoryId].collected_at);
    }

    /// @notice function for compute resource factory at time
    /// @param _type type of factory
    /// @param _level level of factory
    /// @param _collected_at timestamp for collect
    /// @return count of resources
    function _resourcesAtTime(FactoryType _type, uint8 _level, uint256 _collected_at) public view returns(uint256) {
        return worktimeAtDate(_collected_at) * (getProductsPerMinute(_type, _level) + getBonusPerMinute(_type, _level));
    }

    /// @notice function for compute resource factory at time
    /// @dev wrapper over _resourcesAtTime
    /// @param _factoryId id of factory
    /// @return count of resources
    function resourcesAtTime(uint256 _factoryId) public view returns(uint256) {
        Factory storage factory = factories[_factoryId];
        return _resourcesAtTime(factory.ftype, factory.level, factory.collected_at);
    }

    /// @notice function for collect resource
    /// @param _factory factory object
    /// @param _user user object
    /// @return count of resources
    function _collectResource(Factory storage _factory, User storage _user) internal returns(uint256) {
        uint256 resources = _resourcesAtTime(_factory.ftype, _factory.level, _factory.collected_at);
        _user.resources[uint8(_factory.ftype)] = _user.resources[uint8(_factory.ftype)].add(resources);
        _factory.collected_at = now;

        emit CollectResources(_factory.ftype, resources);
        return resources;
    }

    /// @notice function for collect all resources from all factories
    /// @dev wrapper over _collectResource
    function collectResources() public onlyExistingUser {
        uint256 index = addressToUser[msg.sender];
        User storage user = users[index];
        uint256[] storage factoriesIds = userToFactories[addressToUser[msg.sender]];

        for (uint256 i = 0; i < factoriesIds.length; i++) {
            _collectResource(factories[factoriesIds[i]], user);
        }
    }

}