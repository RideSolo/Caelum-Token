# Deployment order

 - Deploy `CaelumToken.sol`
 - Deploy `CaelumMasternode.sol`
 - Deploy `CaelumMiner.sol`

 On all deployed contract:
 - Call `setTokenContract` with the deployed `CaelumToken.sol` address
 - Call `setMiningContract` with the deployed `CaelumMiner.sol` address
 - Call `setMasternodeContract` with the deployed `CaelumMasternode.sol`
   address

On `CaelumMasternode.sol`

 - Call `addGenesis` if you have genesis accounts to be included

On `CaelumToken.sol`

### Multiple contract usage
Caelum token uses multiple deployed contracts, primarily due to Ethereum contract size limits. This approach leads to a couple of unwanted, but unavoidable situations, who leads in turn to some warnings raised when the code is run trough a security analystic tool.

**Powerfull ownership**
Because the contracts need to interact with each other, yet still remain inaccessible from anyone except the contract, Caelum uses a lot of `modifiers`. Modifiers are small code snippets, who guard your function against a set of predefined rules and conditions. One of the most commonly known modifier in smart contracts is the `onlyOwner` modifier, who restricts anyone other then the contract owner to call a specific function.

Caelum uses 5 modifiers throughout the code.

 - `onlyTokenContract` - Only the deployed token contract is allowed to call this function.
 - `onlyMiningContract` - Only the deployed mining contract is allowed to call this function.
 - `onlyMasternodeContract` - Only the deployed masternode contract is allowed to call this function
 - `onlyVotingContract` - Only the deployed voting contract is allowed to call this function
 - `onlyOwner` - Only the contract owner is allowed to call this function

Since our contracts interact, a vast majority of our contract functions are protected with one of the above modifiers. This results in a powerfull ownership, since many functions depend on a single address to exectute. Since those addresses are contracts, there is no direct risk involved if the primary owner account would be compromised.

Another factor is the way we set the remote contract's addresses. This is best described by this snippet of our contract

    function setMiningContract(address _contract) onlyOwner public {
        require (now <= publishedDate + 10 days);
        _contract_miner = _contract;
    }

    function VoteForMiningContract(address _contract) onlyVotingContract external{
        _contract_voting = _contract;
    }

As you can tell from the code, the contract owner is allowed to set the external mining contract's address during the first 10 days after the initial contract has been deployed.  The purpose of this 10 day allowance is to make upgrades to the external contracts if they would be needed. After 10 days, the addresses are locked in forever, unless the community agrees by a majority voting that the contracts are still allowed to be updated. As with any voting proposal in Caelum, this is subjects to a set of strict rules, including:

 - Only one proposal is allowed every 90 days
 - A majority of minimum 60% is required for a proposal to pass

Should any contract upgrade be necessary after some time, we can put up a proposal to change the external contract. Users can then first checkout the upgraded contract, and decide to approve or to reject the new contract.

Combined, all these `modifiers` will trigger a warning that the contract has `powerfull owners`.


**Use of Now**

Caelum uses the `now` function for basic actions. The `now` function can be slightly influenced by miners, but only to a certain degree. The general rule of thumb is that if you can handle a `now` manipulation of about 120 seconds, the function is safe to use. Caelum uses the `now` function to estimate days, so the potential influence on the timestamp has no effects on our code.




# Quickstart guide

Everyone must swap the old CLM tokens ( deployed at `0x7600bF5112945F9F006c216d5d6db0df2806eDc6` or `0x16Da16948e5092A3D2aA71Aca7b57b8a9CFD8ddb`). This process is fully automated in a way that no human interaction is needed, thus can be considered a safe option to swap tokens.

Due to blockchain and platform limitations, it is impossible to simply clone all masternode data and award new tokens to the holders. By doing so, it would become impossible for the masternode holders to withdraw any of the new tokens, since an approval is needed and this can only be granted by the holder himself.

**If you have any masternodes:**

Use the `withdrawCollateral` function on the old contract to retrieve all your tokens.
It is recommended to withdraw all your CLM tokens in a single transaction. For example, if you have 2 masternodes, then you should call the `withdrawCollateral` function with value `1000000000000` to withdraw both masternodes. Follow the guide below to swap your tokens.

### General guidelines

**Step 1:** On the old contract, call the `approve` function with the new contract address, and the amount of tokens you hold. Remember to add 8 decimals at the end. The best way to copy-paste your balance is to call the `balanceOf` function with your address. You can use the return value produced as value.

**Step 2:** After the approval function has confirmed, go to the new contract code.

#### -  If you swap within 24h after contract deployment:

From the dropdownbox on MyEtherWallet, select the function `upgradeTokens`. As function parameter, you must enter the token address you are swapping against new tokens.

If you want to swap the regular CLM tokens, use address `0x7600bF5112945F9F006c216d5d6db0df2806eDc6`
To swap the failed deployed contract tokens, use address `0x16da16948e5092a3d2aa71aca7b57b8a9cfd8ddb`

Confirm the action by clicking the `Write` button.

The contract will transfer your old tokens to the new contract, and send you new tokens instead. Please note that this function takes your entire old balance and swaps it 1:1 with new tokens.


#### -  If you swap later then 24h after contract deployment:

From the dropdownbox on MyEtherWallet, select the function `manualUpgradeTokens`. As function parameter, you must enter the token address you are swapping against new tokens.

If you want to swap the regular CLM tokens, use address `0x7600bF5112945F9F006c216d5d6db0df2806eDc6`
To swap the failed deployed contract tokens, use address `0x16da16948e5092a3d2aa71aca7b57b8a9cfd8ddb`

Confirm the action by clicking the `Write` button.

The contract will put you in queue for manual verification of your tokens origins. The contract owners will manually approve or decline the swap request.  A decline will only happen if you have tokens generated 24h after the contract upgrade, or malicious attempts to continue solo mining on the old token contract.


**Step 4:** After this transaction has been confirmed on the blockchain, you should see the new tokens in your wallet. To verify, you can use the `balanceOf` function to quickly check this.


# Swapping 101
