pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol";

contract MyMillions is Ownable {
    using SafeMath for uint256;

    event CreateUser(uint256 _index, address _address, uint256 _balance);
    event ReferralRegister(uint256 _refferalId, uint256 _userId);
    
    struct User {
        address addr;           // user address
        uint256 balance;        // balance of account
        uint256 totalPay;       // sum of all input pay
        uint256[] referrals;    // first layer referrals ids
    }
    
    User[] public users;
    mapping (address => uint256) public addressToUser;
    
    struct Factory {
        
    }
    
    Factory[] woodFactories;
    Factory[] metallFactories;
    Factory[] oilFactories;
    Factory[] preciousMetallFactories;
    
    constructor() public {
        users.push(User(0x0, 0, 0, new uint256[](0)));  // for find by addressToUser map
    }
    
    /**
     * @dev register for only new users with min pay
     */
    function register() public payable returns(uint256) {
        require(addressToUser[msg.sender] == 0);
        
        User memory user = User(msg.sender, msg.value, msg.value, new uint256[](0));
        uint256 index = users.push(user) - 1;
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

    function referralsOf() public view returns (uint256[]) {
        return users[addressToUser[msg.sender]].referrals;
    }

    function balanceOf() public view returns (uint256) {
        return users[addressToUser[msg.sender]].balance;
    }
    
    function buyWoodFactory() public payable {
        
    }
    
}
