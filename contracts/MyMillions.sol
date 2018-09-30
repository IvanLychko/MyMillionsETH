pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol";

contract MyMillions is Ownable {
    using SafeMath for uint256;
    
    struct User {
        address addr;           // user address
        uint256 balance;        // balance of account
        uint256 totalPay;       // sum of all input pay
        uint256[] referrals;    // first layer referrals
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
    
    function register() public payable returns(uint256) {
        require(addressToUser[msg.sender] == 0);
        
        User memory user = User(msg.sender, 0, 0, new uint256[](0));
        uint256 index = users.push(user) - 1;
        addressToUser[msg.sender] = index;
        
        return index;
    }
    /**
     * @dev essentially the same as buy, but instead of you sending ether 
     * from your wallet, it uses your unwithdrawn earnings.
     * -functionhash- 0x349cdcac (using ID for affiliate)
     * -functionhash- 0x82bfc739 (using address for affiliate)
     * -functionhash- 0x079ce327 (using name for affiliate)
     * @param _refId the ID of the user who gets the affiliate fee
     */
    function register(uint256 _refId) public payable returns(uint256) {
        require(_refId < users.length);
        
        uint256 index = register();
        users[_refId].referrals.push(index);
        
        return index;
    }
    
    function buyWoodFactory() public payable {
        
    }
    
}
