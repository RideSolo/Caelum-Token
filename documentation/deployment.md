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

 - Call `addOwnToken` to approve your own token as masternode collateral
