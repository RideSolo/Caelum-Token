pragma solidity ^0.4.25;

import "./interfaces/ICaelumMiner.sol";
import "./CaelumMasternodeImproved.sol";
import "./CaelumModifier.sol";

contract CaelumMasternode is CaelumMasternodeImproved {

    bool minerSet = false;
    bool tokenSet = false;

    /**
     * @dev Use this to externaly call the _arrangeMasternodeFlow function. ALWAYS set a modifier !
     */
    function _externalArrangeFlow()  public {
        _arrangeMasternodeFlow();
    }

    /**
     * @dev Use this to externaly call the addMasternode function. ALWAYS set a modifier !
     */
    function _externalAddMasternode(address _received) external {
        addMasternode(_received);
    }

    /**
     * @dev Use this to externaly call the deleteMasternode function. ALWAYS set a modifier !
     */
    function _externalStopMasternode(address _received) external {
        deleteMasternode(getLastPerUser(_received));
    }

    function getMiningReward() public view returns(uint) {
        return ICaelumMiner(_contract_miner).getMiningReward();
    }

    address cloneDataFrom = 0x7600bF5112945F9F006c216d5d6db0df2806eDc6;

    function getDataFromContract () onlyOwner public returns(uint) {

        CaelumMasternode prev = CaelumMasternode(cloneDataFrom);
        (uint epoch,
        uint candidate,
        uint round,
        uint miningepoch,
        uint globalreward,
        uint powreward,
        uint masternodereward,
        uint usercounter) = prev.contractProgress();

        //masternodeEpoch = epoch;
        masternodeRound = round;
        miningEpoch = miningepoch;
        rewardsProofOfWork = powreward;
        rewardsMasternode = masternodereward;

    }

}
