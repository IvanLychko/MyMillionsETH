pragma solidity ^0.4.24;

import "./Math.sol";
import "./SafeMath.sol";

contract LeaderSystem {
    using SafeMath for uint256;

    event NewLeader(uint256 _indexTable, address _addr, uint256 _index, uint256 _sum);
    event LeadersClear(uint256 _indexTable);
    event Test(uint256 _i);
    event Addr(address _a, uint256 _sum);

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

    function _updateLeadersTable(uint256 i, address _addr, uint256 _value) internal {
        if (now > leaders[i].timestampEnd) _clearLeadersTable(i);

        LeadersTable storage leader = leaders[i];
        address[] storage leadersUser = leader.leaders;

        uint256 newSum = leader.users[_addr].add(_value);
        leader.users[_addr] = newSum;

        if (newSum < leader.minSum) return;

        uint256 newLength = Math.min(leadersUser.length + 1, leadersCount);
        uint256 newCount = 0;
        address[] memory result = new address[](newLength);
        bool isAdded = false;
        bool isExist = false;

        for (uint j = 0; j < newLength; j++) {
            uint ja = j;
            if (isAdded) {
                ja--;
//                if (isExist) ja++;
            }

            if (leadersUser[j] == 0x0) {
                if (!isAdded) {
                    isAdded = true;
                    result[newCount] = _addr;

                    emit Test(0);
                    emit NewLeader(i, _addr, newCount, newSum);
                }
                else {
                    result[newCount] = leadersUser[ja];
                    emit Test(4);
                }

                newCount++;
                break;
            }

            if (_addr == leadersUser[j]) {
                if (isAdded) {
                    isExist = true;
                    result[newCount] = leadersUser[j - 1];
                    newCount++;
                    emit Test(31);
                }
                else {
                    isAdded = true;
                    result[newCount] = _addr;
//                    newCount++;
                }
                emit Test(3);
                continue;
            }

            if (newSum > leader.users[leadersUser[j]] && !isAdded) {
                isAdded = true;
                result[newCount] = _addr;

                emit Test(1);
                emit NewLeader(i, _addr, newCount, newSum);
            }
            else {
                result[newCount] = leadersUser[ja];
                emit Test(2);
            }

            newCount++;
        }

        if (j >= newLength && isAdded) {
            result[newLength - 1] = leadersUser[newLength - 2];
        }

        emit Addr(result[0], leader.users[result[0]]);
        emit Addr(result[1], leader.users[result[1]]);
        emit Addr(result[2], leader.users[result[2]]);
        emit Addr(result[3], leader.users[result[3]]);
        emit Addr(result[4], leader.users[result[4]]);
        emit Addr(result[5], leader.users[result[5]]);
        emit Addr(result[6], leader.users[result[6]]);

        leader.leaders = result;
    }

    function _updateLeaders(address _addr, uint256 _value) internal {
//        for (uint i = 0; i < leaders.length; i++) {
            _updateLeadersTable(0, _addr, _value);
//        }
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