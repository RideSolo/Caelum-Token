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

On `CaelumMiner.sol`

  - Call `getDataFromContract` with the old contract address to copy the data

# Addresses and ABI

### CaelumToken:

Deployed at `0xc71a7ecd96fef6e34a5c296bee9533f1deb0e3c1`

### CaelumMasternode:

Deployed at `0x3b1b3f92d85ef134fb253c1e976346430eab6b37`

### CaelumMiner:

Deployed at `0x28723f0bb2c2040caa9e2e8fe487bca7c00fc300`

### CaelumModifierVoting

Deployed at `0xdf33254137ec363f6e0076ff6eac58ca1ecb409e`


Masternode modifier set.
Masternode addOwner set.
Masternode addGenesis set.

TODO: getDataFromContract

Token modifier set.

Miner modifier set.

TODO: getDataFromContract
