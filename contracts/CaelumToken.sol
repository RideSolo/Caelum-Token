pragma solidity ^ 0.4 .25;

import "./CaelumAcceptERC20.sol";
import "./libs/StandardToken.sol";
import "./CaelumModifier.sol";


contract CaelumToken is CaelumModifier, CaelumAcceptERC20, StandardToken {
    using SafeMath
    for uint;

    ERC20 previousContract;

    bool public swapClosed = false;
    uint public swapCounter;

    string public symbol = "CLM";
    string public name = "Caelum Token";
    uint8 public decimals = 8;
    uint256 public totalSupply = 2100000000000000;


    address public allowedSwapAddress01;
    address public allowedSwapAddress02;

    uint swapStartedBlock;


    mapping(address => uint) manualSwaps;
    mapping(address => bool) hasSwapped;


    constructor() public {
        swapStartedBlock = now;
    }

    // TESTNET: REMOVE BEFORE LIVE !!!
    // MUST BE HARDCODED.
    function setSwap(address _t) public {
        allowedSwapAddress01 = _t;
    }

    /**
     * @dev Allow users to upgrade from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * @param _token Token the user wants to swap.
     */
    function upgradeTokens(address _token) public {
        require(!swapClosed, "Swap function is closed. Please use the manualUpgradeTokens function");
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now <= swapStartedBlock + 1 days, "Timeframe exipred, please use manualUpgradeTokens function");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {
            require(ERC20(_token).balanceOf(msg.sender) == 0);
            hasSwapped[msg.sender] = true;
            balances[msg.sender] = balances[msg.sender].add(amountToUpgrade);
            emit Transfer(this, msg.sender, amountToUpgrade);
        }
    }

    /**
     * @dev Allow users to upgrade manualy from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * Used when a user failed to swap in time.
     * Dev should manually verify the origin of these tokens before allowing it.
     * @param _token Token the user wants to swap.
     */
    function manualUpgradeTokens(address _token) public {
        require(!swapClosed, "Swap function is closed. Please use the manualUpgradeTokens function");
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now <= swapStartedBlock + 1 days, "Timeframe exipred, please use manualUpgradeTokens function");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {
            require(ERC20(_token).balanceOf(msg.sender) == 0);
            hasSwapped[msg.sender] = true;
            manualSwaps[msg.sender] = amountToUpgrade;
        }
    }



    /**
     * @dev Due to some bugs in the previous contracts, a handfull of users will
     * be unable to fully withdraw their masternodes. Owner can replace those tokens
     * who are forever locked up in the old contract with new ones.

     */
    function getLockedTokens(address _holder) public view returns(uint) {
        return CaelumAcceptERC20(this).tokens(this, _holder);
    }
    /**
     * @dev Approve a request for manual token swaps
     * @param _holder Holder The user who requests a swap.
     */
    function approveManualUpgrade(address _holder) onlyOwner public {
        balances[_holder] = balances[_holder].add(manualSwaps[_holder]);
        emit Transfer(this, _holder, manualSwaps[_holder]);
    }

    /**
     * @dev Decline a request for manual token swaps
     * @param _holder Holder The user who requests a swap.
     */
    function declineManualUpgrade(address _holder) onlyOwner public {
        delete manualSwaps[_holder];
        delete hasSwapped[_holder];
    }

    /**
     * @dev Due to some bugs in the previous contracts, a handfull of users will
     * be unable to fully withdraw their masternodes. Owner can replace those tokens
     * who are forever locked up in the old contract with new ones.

     */
    function replaceLockedTokens(address _holder) onlyOwner public {
        uint amountLocked = getLockedTokens(_holder);
        balances[_holder] = balances[_holder].add(amountLocked);
        emit Transfer(this, _holder, amountLocked);
        hasSwapped[msg.sender] = true;
    }

    /**
     * @dev Used to grant the mining contract rights to reward users.
     * As our contracts are separate, we call this function with modifier onlyMiningContract to sent out rewards.
     * @param _receiver Who receives the mining reward.
     * @param _amount What amount to reward.
     */
    function rewardExternal(address _receiver, uint _amount) onlyMiningContract external {
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(this, _receiver, _amount);
    }
}
