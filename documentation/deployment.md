# Deployment order

### Step 1: Deploy contracts

  - Deploy `CaelumToken.sol`
  - Deploy `CaelumMasternode.sol`
  - Deploy `CaelumMiner.sol`
  - Deploy `CaelumModifierVoting.sol`

### Step 2: Link contracts

 On the `CaelumModifierVoting.sol` deployed contract:

  - Call `setTokenContract` with the deployed `CaelumToken.sol` address
  - Call `setMiningContract` with the deployed `CaelumMiner.sol` address
  - Call `setMasternodeContract` with the deployed `CaelumMasternode.sol` address

On `CaelumMasternode.sol`
  - Call `setModifierContract` with the deployed `CaelumModifierVoting` address
  - Call `addGenesis` if you have genesis accounts to be included

On `CaelumToken.sol`
  - Call `setModifierContract` with the deployed `CaelumModifierVoting` address
  - Call `addOwnToken` to approve your own token as masternode collateral

On `CaelumMiner.sol`
   - Call `setModifierContract` with the deployed `CaelumModifierVoting` address
   - Call `getDataFromContract` with the old contract address to copy the data

If you completed all steps above, you are now ready to start mining Caelum.

# Addresses and ABI

### CaelumToken:

Deployed at `0xc71a7ecd96fef6e34a5c296bee9533f1deb0e3c1`

### CaelumMasternode:

Deployed at `0x3b1b3f92d85ef134fb253c1e976346430eab6b37`

### CaelumMiner:

Deployed at `0xa38fcedd23de2191dc27f9a0240ac170be0a14fe`

### CaelumModifierVoting

Deployed at `0xdf33254137ec363f6e0076ff6eac58ca1ecb409e`
