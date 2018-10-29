## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| contracts/flattened/CaelumToken.sol | 3decde7bf5a11d0362eaad0a2f1fa8bb5b8ea769 |


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
| **ERC20Basic** | Implementation |  |||
| └ | totalSupply | Public ❗️ |   | |
| └ | balanceOf | Public ❗️ |   | |
| └ | transfer | Public ❗️ | 🛑  | |
||||||
| **ERC20** | Implementation | ERC20Basic |||
| └ | allowance | Public ❗️ |   | |
| └ | transferFrom | Public ❗️ | 🛑  | |
| └ | approve | Public ❗️ | 🛑  | |
||||||
| **BasicToken** | Implementation | ERC20Basic |||
| └ | totalSupply | Public ❗️ |   | |
| └ | transfer | Public ❗️ | 🛑  | |
| └ | balanceOf | Public ❗️ |   | |
||||||
| **StandardToken** | Implementation | ERC20, BasicToken |||
| └ | transferFrom | Public ❗️ | 🛑  | |
| └ | approve | Public ❗️ | 🛑  | |
| └ | allowance | Public ❗️ |   | |
| └ | increaseApproval | Public ❗️ | 🛑  | |
| └ | decreaseApproval | Public ❗️ | 🛑  | |
||||||
| **IRemoteFunctions** | Interface |  |||
| └ | _externalAddMasternode | External ❗️ | 🛑  | |
| └ | _externalStopMasternode | External ❗️ | 🛑  | |
||||||
| **ERC20Interface** | Implementation |  |||
| └ | totalSupply | Public ❗️ |   | |
| └ | balanceOf | Public ❗️ |   | |
| └ | allowance | Public ❗️ |   | |
| └ | transfer | Public ❗️ | 🛑  | |
| └ | approve | Public ❗️ | 🛑  | |
| └ | transferFrom | Public ❗️ | 🛑  | |
||||||
| **CaelumAcceptERC20** | Implementation | CaelumModifier |||
| └ | addOwnToken | Public ❗️ | 🛑  | onlyOwner |
| └ | addToWhitelist | Internal 🔒 | 🛑  | |
| └ | isAcceptedToken | Internal 🔒 |   | |
| └ | getAcceptedTokenAmount | Internal 🔒 |   | |
| └ | isValid | Internal 🔒 |   | |
| └ | listAcceptedTokens | Public ❗️ |   | |
| └ | getTokenDetails | Public ❗️ |   | |
| └ | depositCollateral | Public ❗️ | 🛑  | |
| └ | withdrawCollateral | Public ❗️ | 🛑  | |
| └ | setDataStorage | Public ❗️ | 🛑  | onlyOwner |
||||||
| **CaelumToken** | Implementation | CaelumAcceptERC20, StandardToken |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | setSwap | Public ❗️ | 🛑  | |
| └ | upgradeTokens | Public ❗️ | 🛑  | |
| └ | manualUpgradeTokens | Public ❗️ | 🛑  | |
| └ | getLockedTokens | Public ❗️ |   | |
| └ | approveManualUpgrade | Public ❗️ | 🛑  | onlyOwner |
| └ | declineManualUpgrade | Public ❗️ | 🛑  | onlyOwner |
| └ | replaceLockedTokens | Public ❗️ | 🛑  | onlyOwner |
| └ | rewardExternal | External ❗️ | 🛑  | onlyMiningContract |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
