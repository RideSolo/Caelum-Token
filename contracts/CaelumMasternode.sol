pragma solidity 0.4.25;


import "./CaelumAbstractMasternode.sol";


contract CaelumMasternode is CaelumAbstractMasternode {

    bool minerSet = false;
    bool tokenSet = false;

    /**
     * @dev Use this to externaly call the _arrangeMasternodeFlow function. ALWAYS set a modifier !
     */

    function _externalArrangeFlow() onlyMiningContract public {
        _arrangeMasternodeFlow();
    }

    /**
     * @dev Use this to externaly call the addMasternode function. ALWAYS set a modifier !
     */
    function _externalAddMasternode(address _received) onlyTokenContract public {
        addMasternode(_received);
    }

    /**
     * @dev Use this to externaly call the deleteMasternode function. ALWAYS set a modifier !
     */
    function _externalStopMasternode(address _received) onlyTokenContract public {
        deleteMasternode(getLastActiveBy(_received));
    }

    function getMiningReward() public view returns(uint) {
        return ICaelumMiner(_contract_miner).getMiningReward();
    }

    address cloneDataFrom = 0x7600bF5112945F9F006c216d5d6db0df2806eDc6;

    function getDataFromContract() onlyOwner public returns(uint) {

        CaelumMasternode prev = CaelumMasternode(cloneDataFrom);
        (
          uint epoch,
          uint candidate,
          uint round,
          uint miningepoch,
          uint globalreward,
          uint powreward,
          uint masternodereward,
          uint usercounter
        ) = prev.contractProgress();

        //masternodeEpoch = epoch;
        masternodeRound = round;
        miningEpoch = miningepoch;
        rewardsProofOfWork = powreward;
        rewardsMasternode = masternodereward;
    }

}
