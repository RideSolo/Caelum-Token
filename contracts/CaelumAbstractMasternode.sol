pragma solidity 0.4.25;

import "./libs/SafeMath.sol";
import "./interfaces/ICaelumMiner.sol";
import "./CaelumModifier.sol";


contract CaelumAbstractMasternode is CaelumModifier {

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

    address cloneDataFrom = 0x7600bF5112945F9F006c216d5d6db0df2806eDc6;

    event NewMasternode(address candidateAddress, uint timeStamp);
    event RemovedMasternode(address candidateAddress, uint timeStamp);


    address [] public genesisList = [
      0xdb93ce3cca2444ce5da5522a85758af79af0092d,
      0x375e97e59de97be46d332ba17185620b81bdb7cc,
      0x14db686439aad3c076b793335bc14d9039f32c54,
      0x1ba4b0280163889e7ee4ab5269c442971f48d13e,
      0xe4ac657af0690e9437f36d3e96886dc880b24404,
      0x8fcf0027e1e91a12981fbc6371de39a269c3a47,
      0x3d664b7b0eb158798f3e797e194fee50dd748742,
      0xb85ac167079020d93033a014efead75f14018522,
      0xc6d00915cbcf9abe9b27403f8d2338551f4ac43b,
      0x5256fe3f8e50e0f7f701525e814a2767da2cca06,
      0x2cf23c6610a70d58d61efbdefd6454960b200c2c,
      0x002Bb739Cf93b29786d96Cc04172878487ABA988
    ];

    function addGenesis() onlyOwner public {
        require(!genesisAdded);

        for (uint i=0; i<genesisList.length; i++) {
          addMasternode(genesisList[i]);
        }

        genesisAdded = true; // Forever lock this.
    }

    function addMasternode(address _candidate) internal {
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

    function updateMasternode(uint _index) internal returns(bool) {
        masternodeByIndex[_index].startingRound++;
        return true;
    }

    function updateMasternodeAsTeamMember(address _candidate) internal returns(bool) {
        userByAddress[_candidate].isTeamMember = true;
        return (true);
    }

    function deleteMasternode(uint _index) internal {
        address getUserFrom = getUserFromID(_index);
        userByAddress[getUserFrom].isActive = false;
        masternodeByIndex[_index].isActive = false;
        userCounter--;
    }

    function getLastActiveBy(address _candidate) public view returns(uint) {
      uint lastFound;
      for (uint i = 0; i < userByAddress[_candidate].indexcounter.length; i++) {
          if (masternodeByIndex[userByAddress[_candidate].indexcounter[i]].isActive == true) {
              lastFound = masternodeByIndex[userByAddress[_candidate].indexcounter[i]].storedIndex;
          }
      }
      return lastFound;
    }

    function userHasActiveNodes(address _candidate) public view returns(bool) {

        bool lastFound;

        for (uint i = 0; i < userByAddress[_candidate].indexcounter.length; i++) {
            if (masternodeByIndex[userByAddress[_candidate].indexcounter[i]].isActive == true) {
                lastFound = true;
            }
        }
        return lastFound;
    }

    function setMasternodeCandidate() internal returns(address) {

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

    function calculateRewardStructures() internal {
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

    function _arrangeMasternodeFlow() internal {
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

    function getDataFromContract() onlyOwner public returns(uint) {

        CaelumAbstractMasternode prev = CaelumAbstractMasternode(cloneDataFrom);
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
