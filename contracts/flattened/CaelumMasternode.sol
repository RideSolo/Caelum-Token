pragma solidity ^0.4.25;

// File: contracts\libs\SafeMath.sol

//solium-disable linebreak-style
pragma solidity ^0.4.25;

library SafeMath {

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts\interfaces\ICaelumMiner.sol

interface ICaelumMiner {
    function getMiningReward() external returns (uint) ;
}

// File: contracts\libs\Ownable.sol

//solium-disable linebreak-style
pragma solidity ^0.4.25;

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @dev Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts\CaelumModifier.sol

contract CaelumModifier is Ownable {

    address public _contract_miner;
    address public _contract_token;
    address public _contract_masternode;

    modifier onlyMiningContract() {
        require(msg.sender == _contract_miner);
        _;
    }

    modifier onlyTokenContract() {
        require(msg.sender == _contract_token);
        _;
    }

    modifier onlyMasternodeContract() {
        require(msg.sender == _contract_masternode);
        _;
    }

    function setMiningContract(address _contract) onlyOwner public {
        _contract_miner = _contract;
    }

    function setTokenContract(address _contract) onlyOwner public {
        _contract_token = _contract;
    }

    function setMasternodeContract(address _contract) onlyOwner public {
        _contract_masternode = _contract;
    }

}

// File: contracts\CaelumMasternodeImproved.sol

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

// File: contracts\CaelumMasternode.sol

contract CaelumMasternode is CaelumMasternodeImproved {

    bool minerSet = false;
    bool tokenSet = false;

    /**
     * @dev Use this to externaly call the _arrangeMasternodeFlow function. ALWAYS set a modifier !
     */

    function _externalArrangeFlow() public {
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

    function getDataFromContract() onlyOwner public returns(uint) {

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
