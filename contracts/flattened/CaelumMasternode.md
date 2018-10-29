## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| contracts/flattened/CaelumMasternode.sol | 7b65cfd5b6b54292d6f966bdc72af16a18837b4a |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **SafeMath** | Library |  |||
| └ | mul | Internal 🔒 |   | |
| └ | div | Internal 🔒 |   | |
| └ | sub | Internal 🔒 |   | |
| └ | add | Internal 🔒 |   | |
| └ | mod | Internal 🔒 |   | |
||||||
| **ICaelumMiner** | Interface |  |||
| └ | getMiningReward | External ❗️ | 🛑  | |
||||||
| **Ownable** | Implementation |  |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | renounceOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | transferOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | _transferOwnership | Internal 🔒 | 🛑  | |
||||||
| **CaelumModifier** | Implementation | Ownable |||
| └ | setMiningContract | Public ❗️ | 🛑  | onlyOwner |
| └ | setTokenContract | Public ❗️ | 🛑  | onlyOwner |
| └ | setMasternodeContract | Public ❗️ | 🛑  | onlyOwner |
||||||
| **CaelumAbstractMasternode** | Implementation | CaelumModifier |||
| └ | addGenesis | Public ❗️ | 🛑  | onlyOwner |
| └ | closeGenesis | Public ❗️ | 🛑  | onlyOwner |
| └ | addMasternode | Internal 🔒 | 🛑  | |
| └ | updateMasternode | Internal 🔒 | 🛑  | |
| └ | updateMasternodeAsTeamMember | Internal 🔒 | 🛑  | |
| └ | deleteMasternode | Internal 🔒 | 🛑  | |
| └ | getLastActiveBy | Public ❗️ |   | |
| └ | userHasActiveNodes | Public ❗️ |   | |
| └ | setMasternodeCandidate | Internal 🔒 | 🛑  | |
| └ | getFollowingCandidate | Public ❗️ |   | |
| └ | calculateRewardStructures | Internal 🔒 | 🛑  | |
| └ | setBaseRewards | Internal 🔒 | 🛑  | |
| └ | _arrangeMasternodeFlow | Internal 🔒 | 🛑  | |
| └ | isMasternodeOwner | Public ❗️ |   | |
| └ | belongsToUser | Public ❗️ |   | |
| └ | getLastPerUser | Public ❗️ |   | |
| └ | getUserFromID | Public ❗️ |   | |
| └ | getMiningReward | Public ❗️ |   | |
| └ | masternodeInfo | Public ❗️ |   | |
| └ | contractProgress | Public ❗️ |   | |
| └ | getDataFromContract | Public ❗️ | 🛑  | |
||||||
| **CaelumMasternode** | Implementation | CaelumAbstractMasternode |||
| └ | _externalArrangeFlow | Public ❗️ | 🛑  | onlyMiningContract |
| └ | _externalAddMasternode | External ❗️ | 🛑  | onlyTokenContract |
| └ | _externalStopMasternode | External ❗️ | 🛑  | onlyTokenContract |
| └ | getMiningReward | Public ❗️ |   | |
| └ | getDataFromContract | Public ❗️ | 🛑  | onlyOwner |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
