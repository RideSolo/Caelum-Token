pragma solidity 0.4.25;

import "./CaelumAcceptERC20.sol";

contract CaelumToken is CaelumAcceptERC20, StandardToken {
    using SafeMath for uint;

    ICaelumMasternode masternodeInterface;

    bool public swapClosed = false;
    bool isOnTestNet = true;

    string public symbol = "CLM";
    string public name = "Caelum Token";
    uint8 public decimals = 8;
    uint256 public totalSupply = 2100000000000000;

    address allowedSwapAddress01 = 0x7600bF5112945F9F006c216d5d6db0df2806eDc6;
    address allowedSwapAddress02 = 0x16Da16948e5092A3D2aA71Aca7b57b8a9CFD8ddb;

    uint swapStartedBlock;

    mapping(address => uint) manualSwaps;
    mapping(address => bool) hasSwapped;

    event NewSwapRequest(address _swapper, uint _amount);
    event TokenSwapped(address _swapper, uint _amount);

    constructor() public {
        addOwnToken();
        swapStartedBlock = now;
    }

    /**
     * @dev Allow users to upgrade from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * @param _token Token the user wants to swap.
     */
    function upgradeTokens(address _token) public {
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now <= swapStartedBlock + 1 days, "Timeframe exipred, please use manualUpgradeTokens function");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);

        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));
        require(ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade));
        require(ERC20(_token).balanceOf(msg.sender) == 0);

        tokens[_token][msg.sender] = tokens[_token][msg.sender].add(amountToUpgrade);
        balances[msg.sender] = balances[msg.sender].add(amountToUpgrade);

        emit Transfer(this, msg.sender, amountToUpgrade);
        emit TokenSwapped(msg.sender, amountToUpgrade);

        if(
          ERC20(allowedSwapAddress01).balanceOf(msg.sender) == 0  &&
          ERC20(allowedSwapAddress02).balanceOf(msg.sender) == 0
        ) {
          hasSwapped[msg.sender] = true;
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
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now >= swapStartedBlock + 1 days, "Timeframe incorrect");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {
            require(ERC20(_token).balanceOf(msg.sender) == 0);
            if(
              ERC20(allowedSwapAddress01).balanceOf(msg.sender) == 0  &&
              ERC20(allowedSwapAddress02).balanceOf(msg.sender) == 0
            ) {
              hasSwapped[msg.sender] = true;
            }

            tokens[_token][msg.sender] = tokens[_token][msg.sender].add(amountToUpgrade);
            manualSwaps[msg.sender] = amountToUpgrade;
            emit NewSwapRequest(msg.sender, amountToUpgrade);
        }
    }

    /**
     * @dev Allow users to partially upgrade manualy from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * Used when a user failed to swap in time.
     * Dev should manually verify the origin of these tokens before allowing it.
     * @param _token Token the user wants to swap.
     */
    function manualUpgradePartialTokens(address _token, uint _amount) public {
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now >= swapStartedBlock + 1 days, "Timeframe incorrect");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = _amount; //ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        uint newBalance = ERC20(_token).balanceOf(msg.sender) - (amountToUpgrade);
        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {

            require(ERC20(_token).balanceOf(msg.sender) == newBalance, "Balance error.");

            if(
              ERC20(allowedSwapAddress01).balanceOf(msg.sender) == 0  &&
              ERC20(allowedSwapAddress02).balanceOf(msg.sender) == 0
            ) {
              hasSwapped[msg.sender] = true;
            }

            tokens[_token][msg.sender] = tokens[_token][msg.sender].add(amountToUpgrade);
            manualSwaps[msg.sender] = amountToUpgrade;
            emit NewSwapRequest(msg.sender, amountToUpgrade);
        }
    }

    /**
     * @dev Due to some bugs in the previous contracts, a handfull of users will
     * be unable to fully withdraw their masternodes. Owner can replace those tokens
     * who are forever locked up in the old contract with new ones.
     */
     function getLockedTokens(address _contract, address _holder) public view returns(uint) {
         return CaelumAcceptERC20(_contract).tokens(_contract, _holder);
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
    function declineManualUpgrade(address _token, address _holder) onlyOwner public {
        require(ERC20(_token).transfer(_holder, manualSwaps[_holder]));
        tokens[_token][_holder] = tokens[_token][_holder] - manualSwaps[_holder];
        delete manualSwaps[_holder];
        delete hasSwapped[_holder];
    }

    /**
     * @dev Due to some bugs in the previous contracts, a handfull of users will
     * be unable to fully withdraw their masternodes. Owner can replace those tokens
     * who are forever locked up in the old contract with new ones.
     */
     function replaceLockedTokens(address _contract, address _holder) onlyOwner public {
         uint amountLocked = getLockedTokens(_contract, _holder);
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
    function rewardExternal(address _receiver, uint _amount) onlyMiningContract public {
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(this, _receiver, _amount);
    }

    /**
     * @dev We allow the masternodecontract to add tokens to our whitelist. By this approach,
     * we can move all voting logic to a contract that can be upgraden when needed.
     */
    function addToWhitelistExternal(address _token, uint _amount, uint daysAllowed) onlyMasternodeContract public {
        addToWhitelist( _token, _amount, daysAllowed);
    }

    /**
     * @dev Fetch data from the actual reward. We do this to prevent pools payout out
     * the global reward instead of the calculated ones.
     * By default, pools fetch the `getMiningReward()` value and will payout this amount.
     */
    function getMiningRewardForPool() public view returns(uint) {
        return masternodeInterface.rewardsProofOfWork();
    }

    /**
     * @dev Return the Proof of Work reward from the masternode contract.
     */
    function rewardsProofOfWork() public view returns(uint) {
        return masternodeInterface.rewardsProofOfWork();
    }

    /**
     * @dev Return the masternode reward from the masternode contract.
     */
    function rewardsMasternode() public view returns(uint) {
        return masternodeInterface.rewardsMasternode();
    }

    /**
     * @dev Return the number of masternodes from the masternode contract.
     */
    function masternodeCounter() public view returns(uint) {
        return masternodeInterface.userCounter();
    }

    /**
     * @dev Return the general state from the masternode contract.
     */
    function contractProgress() public view returns
    (
        uint epoch,
        uint candidate,
        uint round,
        uint miningepoch,
        uint globalreward,
        uint powreward,
        uint masternodereward,
        uint usercounter
    )
    {
        return ICaelumMasternode(_contract_masternode()).contractProgress();

    }

    /**
     * @dev pull new masternode contract from the modifier contract
     */
    function setMasternodeContract() internal  {
        masternodeInterface = ICaelumMasternode(_contract_masternode());
    }

    /**
     * Override; For some reason, truffle testing does not recognize function.
     * Remove before live?
     */
    function setModifierContract (address _contract) onlyOwner public {
        require (now <= swapStartedBlock + 10 days);
        _internalMod = InterfaceContracts(_contract);
        setMasternodeContract();
    }

    /**
    * @dev Move the voting away from token. All votes will be made from the voting
    */
    function VoteModifierContract (address _contract) onlyVotingContract external {
        //_internalMod = CaelumModifierAbstract(_contract);
        setModifierContract(_contract);
        setMasternodeContract();
    }

    /**
     * @dev Needed for testnet only. Comment codeblock out before deploy, leave it as example.
     */
    function setSwap(address _contract, address _contract_2) onlyOwner public {
        require (isOnTestNet == true);
        allowedSwapAddress01 = _contract;
        allowedSwapAddress02 = _contract_2;
    }


}
