pragma solidity ^ 0.4 .25;

import "./libs/SafeMath.sol";
import "./CaelumModifier.sol";

contract CaelumMasternodeImproved is CaelumModifier {

    struct MasterNode {
        address accountOwner;
        bool isActive;
        bool isTeamMember;
        uint storedIndex;
        uint startingRound;
        uint nodeCount;
        uint[] indexcounter;

    }

    mapping(address => MasterNode) public userByAddress;
    mapping(uint => MasterNode) public masternodeByIndex;

    uint public userCounter = 0;
    uint public masternodeIDcounter = 0;
    uint public masternodeRound = 0;
    uint public masternodeCandidate;

    uint public MINING_PHASE_DURATION_BLOCKS = 4500;

    uint public miningEpoch;
    uint public rewardsProofOfWork;
    uint public rewardsMasternode;

    bool genesisAdded = false;

    event NewMasternode(address candidateAddress, uint timeStamp);
    event RemovedMasternode(address candidateAddress, uint timeStamp);

    function addGenesis(address _genesis, bool _team) public {
        require(!genesisAdded);

        addMasternode(_genesis);

        if (_team == true) {
            updateMasternodeAsTeamMember(_genesis);
        }
    }

    function closeGenesis() public {
        genesisAdded = true; // Forever lock this.
    }

    function addMasternode(address _candidate) public {

        /**
         * @dev userByAddress is used for general statistic data.
         * All masternode interaction happens by masternodeByIndex!
         */

        userByAddress[_candidate].isActive = true;
        userByAddress[_candidate].accountOwner = _candidate;
        userByAddress[_candidate].storedIndex = masternodeIDcounter;
        userByAddress[_candidate].startingRound = masternodeRound + 1;
        userByAddress[_candidate].indexcounter.push(masternodeIDcounter);

        masternodeByIndex[masternodeIDcounter].isActive = true;
        masternodeByIndex[masternodeIDcounter].accountOwner = _candidate;
        masternodeByIndex[masternodeIDcounter].storedIndex = masternodeIDcounter;
        masternodeByIndex[masternodeIDcounter].startingRound = masternodeRound + 1;

        masternodeIDcounter++;
        userCounter++;
    }

    function updateMasternode(uint _index) public returns(bool) {
        masternodeByIndex[_index].startingRound++;
        return true;
    }

    function updateMasternodeAsTeamMember(address _candidate) public returns(bool) {
        userByAddress[_candidate].isTeamMember = true;
        return (true);
    }

    function deleteMasternode(uint _index) public {
        address getUserFrom = getUserFromID(_index);
        userByAddress[getUserFrom].isActive = false;
        masternodeByIndex[_index].isActive = false;
        delete userByAddress[getUserFrom].indexcounter[_index];
        delete masternodeByIndex[_index];
    }

    function getLastActiveBy(address _candidate) public view returns(uint) {

        uint lastFound;
        for (uint i = 0; i < userByAddress[_candidate].indexcounter.length; i++) {
            if (masternodeByIndex[i].isActive == true) {
                lastFound = i;
            }
        }
        return lastFound;
    }

    function userHasActiveNodes(address _candidate) public view returns(bool) {

        bool lastFound;
        for (uint i = 0; i < userByAddress[_candidate].indexcounter.length; i++) {
            if (masternodeByIndex[i].isActive == true) {
                lastFound = true;
            }
        }
        return lastFound;
    }

    function setMasternodeCandidate() public returns(address) {

        uint hardlimitCounter = 0;

        while (getFollowingCandidate() == 0x0) {
            // We must return a value not to break the contract. Require is a secondary killswitch now.
            require(hardlimitCounter < 6, "Failsafe switched on");
            // Choose if loop over revert/require to terminate the loop and return a 0 address.
            if (hardlimitCounter == 5) return (0);
            masternodeRound = masternodeRound + 1;
            masternodeCandidate = 0;
            hardlimitCounter++;
        }

        if (masternodeCandidate == masternodeIDcounter - 1) {
            masternodeRound = masternodeRound + 1;
            masternodeCandidate = 0;
        }

        for (uint i = masternodeCandidate; i < masternodeIDcounter; i++) {
            if (masternodeByIndex[i].isActive) {
                if (masternodeByIndex[i].startingRound == masternodeRound) {
                    updateMasternode(i);
                    masternodeCandidate = i;
                    return (masternodeByIndex[i].accountOwner);
                }
            }
        }

        masternodeRound = masternodeRound + 1;
        return (0);

    }

    function getFollowingCandidate() public view returns(address _address) {
        uint tmpRound = masternodeRound;
        uint tmpCandidate = masternodeCandidate;

        if (tmpCandidate == masternodeIDcounter - 1) {
            tmpRound = tmpRound + 1;
            tmpCandidate = 0;
        }

        for (uint i = masternodeCandidate; i < masternodeIDcounter; i++) {
            if (masternodeByIndex[i].isActive) {
                if (masternodeByIndex[i].startingRound == tmpRound) {
                    tmpCandidate = i;
                    return (masternodeByIndex[i].accountOwner);
                }
            }
        }

        tmpRound = tmpRound + 1;
        return (0);
    }

    function calculateRewardStructures() public {
        //ToDo: Set
        uint _global_reward_amount = getMiningReward();
        uint getStageOfMining = miningEpoch / MINING_PHASE_DURATION_BLOCKS * 10;

        if (getStageOfMining < 10) {
            rewardsProofOfWork = _global_reward_amount / 100 * 5;
            rewardsMasternode = 0;
            return;
        }

        if (getStageOfMining > 90) {
            rewardsProofOfWork = _global_reward_amount / 100 * 2;
            rewardsMasternode = _global_reward_amount / 100 * 98;
            return;
        }

        uint _mnreward = (_global_reward_amount / 100) * getStageOfMining;
        uint _powreward = (_global_reward_amount - _mnreward);

        setBaseRewards(_powreward, _mnreward);
    }

    function setBaseRewards(uint _pow, uint _mn) internal {
        rewardsMasternode = _mn;
        rewardsProofOfWork = _pow;
    }

    function _arrangeMasternodeFlow() public {
        calculateRewardStructures();
        setMasternodeCandidate();
        miningEpoch++;
    }

    function isMasternodeOwner(address _candidate) public view returns(bool) {
        if (userByAddress[_candidate].indexcounter.length <= 0) return false;
        if (userByAddress[_candidate].accountOwner == _candidate)
            return true;
    }

    function belongsToUser(address _candidate) public view returns(uint[]) {
        return userByAddress[_candidate].indexcounter;
    }

    function getLastPerUser(address _candidate) public view returns(uint) {
        return userByAddress[_candidate].indexcounter[userByAddress[_candidate].indexcounter.length - 1];
    }

    function getUserFromID(uint _index) public view returns(address) {
        return masternodeByIndex[_index].accountOwner;
    }

    function getMiningReward() public view returns(uint) {
        return 50 * 1e8;
    }

    function masternodeInfo(uint _index) public view returns
        (
            address,
            bool,
            uint,
            uint
        ) {
            return (
                masternodeByIndex[_index].accountOwner,
                masternodeByIndex[_index].isActive,
                masternodeByIndex[_index].storedIndex,
                masternodeByIndex[_index].startingRound
            );
        }

    address cloneDataFrom = 0x7600bF5112945F9F006c216d5d6db0df2806eDc6;

    function contractProgress() public view returns
        (
            uint epoch,
            uint candidate,
            uint round,
            uint miningepoch,
            uint globalreward,
            uint powreward,
            uint masternodereward,
            uint usercount
        ) {
            return (
                0,
                masternodeCandidate,
                masternodeRound,
                miningEpoch,
                getMiningReward(),
                rewardsProofOfWork,
                rewardsMasternode,
                userCounter
            );
        }

    function getDataFromContract() public returns(uint) {

        CaelumMasternodeImproved prev = CaelumMasternodeImproved(cloneDataFrom);
        (uint epoch,
            uint candidate,
            uint round,
            uint miningepoch,
            uint globalreward,
            uint powreward,
            uint masternodereward,
            uint usercount) = prev.contractProgress();


        masternodeRound = round;
        miningEpoch = miningepoch;
        rewardsProofOfWork = powreward;
        rewardsMasternode = masternodereward;

    }
}
