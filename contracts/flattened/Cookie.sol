pragma solidity ^0.4.25;

// File: contracts\flattened\CaelumMasternode.sol

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

// File: contracts\CaelumAbstractMasternode.sol

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
      0x2cf23c6610a70d58d61efbdefd6454960b200c2c
    ];

    function addGenesis(address _genesis, bool _team) onlyOwner public {
        require(!genesisAdded);

        for (uint i=0; i<genesisList.length; i++) {
          addMasternode(genesisList[i]);
        }


        if (_team == true) {
            updateMasternodeAsTeamMember(_genesis);
        }
    }

    function closeGenesis() onlyOwner public {
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

// File: contracts\CaelumMasternode.sol

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
    function _externalAddMasternode(address _received) onlyTokenContract external {
        addMasternode(_received);
    }

    /**
     * @dev Use this to externaly call the deleteMasternode function. ALWAYS set a modifier !
     */
    function _externalStopMasternode(address _received) onlyTokenContract external {
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

// File: contracts\flattened\CaelumMiner.sol

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

// File: contracts\libs\ExtendedMath.sol

//solium-disable linebreak-style
pragma solidity ^0.4.25;

library ExtendedMath {
    function limitLessThan(uint a, uint b) internal pure returns(uint c) {
        if (a > b) return b;
        return a;
    }
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

// File: contracts\interfaces\ICaelumMasternode.sol

interface ICaelumMasternode {
    function _externalArrangeFlow() external;
    function rewardsProofOfWork() external returns (uint) ;
    function rewardsMasternode() external returns (uint) ;
    function masternodeCounter() external returns (uint) ;
    function masternodeCandidate() external returns (uint) ;
    function isPartOf(uint) external view returns  (address) ;
    function contractProgress() external view returns (uint, uint, uint, uint, uint, uint, uint, uint);
}

// File: contracts\interfaces\ICaelumToken.sol

interface ICaelumToken {
    function rewardExternal(address, uint) external;
}

// File: contracts\interfaces\EIP918Interface.sol

interface EIP918Interface  {

    /*
     * Externally facing mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     **/
  	function mint(uint256 nonce, bytes32 challenge_digest) external returns (bool success);


	/*
     * Returns the challenge number
     **/
    function getChallengeNumber() external constant returns (bytes32);

    /*
     * Returns the mining difficulty. The number of digits that the digest of the PoW solution requires which
     * typically auto adjusts during reward generation.
     **/
    function getMiningDifficulty() external constant returns (uint);

    /*
     * Returns the mining target
     **/
    function getMiningTarget() external constant returns (uint);

    /*
     * Return the current reward amount. Depending on the algorithm, typically rewards are divided every reward era
     * as tokens are mined to provide scarcity
     **/
    function getMiningReward() external constant returns (uint);

    /*
     * Upon successful verification and reward the mint method dispatches a Mint Event indicating the reward address,
     * the reward amount, the epoch count and newest challenge number.
     **/
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

}

// File: contracts\AbstractERC918.sol

contract AbstractERC918 is EIP918Interface {

    // generate a new challenge number after a new reward is minted
    bytes32 public challengeNumber;

    // the current mining difficulty
    uint public difficulty;

    // cumulative counter of the total minted tokens
    uint public tokensMinted;

    // track read only minting statistics
    struct Statistics {
        address lastRewardTo;
        uint lastRewardAmount;
        uint lastRewardEthBlockNumber;
        uint lastRewardTimestamp;
    }

    Statistics public statistics;

    /*
     * Externally facing mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     **/
    function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);


    /*
     * Internal interface function _hash. Overide in implementation to define hashing algorithm and
     * validation
     **/
    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns (bytes32 digest);

    /*
     * Internal interface function _reward. Overide in implementation to calculate and return reward
     * amount
     **/
    function _reward() internal returns (uint);

    /*
     * Internal interface function _newEpoch. Overide in implementation to define a cutpoint for mutating
     * mining variables in preparation for the next epoch
     **/
    function _newEpoch(uint256 nonce) internal returns (uint);

    /*
     * Internal interface function _adjustDifficulty. Overide in implementation to adjust the difficulty
     * of the mining as required
     **/
    function _adjustDifficulty() internal returns (uint);

}

// File: contracts\CaelumAbstractMiner.sol

contract CaelumAbstractMiner is CaelumModifier, AbstractERC918 {
    /**
     * CaelumMiner contract.
     *
     * We need to make sure the contract is 100% compatible when using the EIP918Interface.
     * This contract is an abstract Caelum miner contract.
     *
     * Function 'mint', and '_reward' are overriden in the CaelumMiner contract.
     * Function '_reward_masternode' is added and needs to be overriden in the CaelumMiner contract.
     */

    using SafeMath for uint;
    using ExtendedMath for uint;

    uint256 public totalSupply = 2100000000000000;

    uint public latestDifficultyPeriodStarted;
    uint public epochCount;
    uint public baseMiningReward = 50;
    uint public blocksPerReadjustment = 512;
    uint public _MINIMUM_TARGET = 2 ** 16;
    uint public _MAXIMUM_TARGET = 2 ** 234;
    uint public rewardEra = 0;

    uint public maxSupplyForEra;
    uint public MAX_REWARD_ERA = 39;
    uint public MINING_RATE_FACTOR = 60; //mint the token 60 times less often than ether

    uint public MAX_ADJUSTMENT_PERCENT = 100;
    uint public TARGET_DIVISOR = 2000;
    uint public QUOTIENT_LIMIT = TARGET_DIVISOR.div(2);
    mapping(bytes32 => bytes32) solutionForChallenge;
    mapping(address => mapping(address => uint)) allowed;

    bytes32 public challengeNumber;
    uint public difficulty;
    uint public tokensMinted;


    Statistics public statistics;

    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
    event RewardMasternode(address candidate, uint amount);

    constructor() public {
        tokensMinted = 0;
        maxSupplyForEra = totalSupply.div(2);
        difficulty = _MAXIMUM_TARGET;
        latestDifficultyPeriodStarted = block.number;
        _newEpoch(0);
    }



    function _newEpoch(uint256 nonce) internal returns(uint) {
        if (tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < MAX_REWARD_ERA) {
            rewardEra = rewardEra + 1;
        }
        maxSupplyForEra = totalSupply - totalSupply.div(2 ** (rewardEra + 1));
        epochCount = epochCount.add(1);
        challengeNumber = blockhash(block.number - 1);
        return (epochCount);
    }

    function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success);

    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns(bytes32 digest) {
        digest = keccak256(challengeNumber, msg.sender, nonce);
        if (digest != challenge_digest) revert();
        if (uint256(digest) > difficulty) revert();
        bytes32 solution = solutionForChallenge[challengeNumber];
        solutionForChallenge[challengeNumber] = digest;
        if (solution != 0x0) revert(); //prevent the same answer from awarding twice
    }

    function _reward() internal returns(uint);

    function _reward_masternode() internal returns(uint);

    function _adjustDifficulty() internal returns(uint) {
        //every so often, readjust difficulty. Dont readjust when deploying
        if (epochCount % blocksPerReadjustment != 0) {
            return difficulty;
        }

        uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
        //assume 360 ethereum blocks per hour
        //we want miners to spend 10 minutes to mine each 'block', about 60 ethereum blocks = one 0xbitcoin epoch
        uint epochsMined = blocksPerReadjustment;
        uint targetEthBlocksPerDiffPeriod = epochsMined * MINING_RATE_FACTOR;
        //if there were less eth blocks passed in time than expected
        if (ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod) {
            uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div(ethBlocksSinceLastDifficultyPeriod);
            uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT);
            // If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined than expected then this is 100.
            //make it harder
            difficulty = difficulty.sub(difficulty.div(TARGET_DIVISOR).mul(excess_block_pct_extra)); //by up to 50 %
        } else {
            uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div(targetEthBlocksPerDiffPeriod);
            uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT); //always between 0 and 1000
            //make it easier
            difficulty = difficulty.add(difficulty.div(TARGET_DIVISOR).mul(shortage_block_pct_extra)); //by up to 50 %
        }
        latestDifficultyPeriodStarted = block.number;
        if (difficulty < _MINIMUM_TARGET) //very difficult
        {
            difficulty = _MINIMUM_TARGET;
        }
        if (difficulty > _MAXIMUM_TARGET) //very easy
        {
            difficulty = _MAXIMUM_TARGET;
        }
    }

    function getChallengeNumber() public view returns(bytes32) {
        return challengeNumber;
    }

    function getMiningDifficulty() public view returns(uint) {
        return _MAXIMUM_TARGET.div(difficulty);
    }

    function getMiningTarget() public view returns(uint) {
        return difficulty;
    }

    function getMiningReward() public view returns(uint) {
        return (baseMiningReward * 1e8).div(2 ** rewardEra);
    }

    function getMintDigest(
        uint256 nonce,
        bytes32 challenge_digest,
        bytes32 challenge_number
    )
    public view returns(bytes32 digesttest) {
        bytes32 digest = keccak256(challenge_number, msg.sender, nonce);
        return digest;
    }

    function checkMintSolution(
        uint256 nonce,
        bytes32 challenge_digest,
        bytes32 challenge_number,
        uint testTarget
    )
    public view returns(bool success) {
        bytes32 digest = keccak256(challenge_number, msg.sender, nonce);
        if (uint256(digest) > testTarget) revert();
        return (digest == challenge_digest);
    }
}

// File: contracts\CaelumMiner.sol

contract CaelumMiner is CaelumAbstractMiner {

    function getCCC() public view returns (address, uint) {
        return (ICaelumMasternode(_contract_token).isPartOf(ICaelumMasternode(_contract_token).masternodeCandidate()), ICaelumMasternode(_contract_token).masternodeCandidate());
    }


    function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success) {

        _hash(nonce, challenge_digest);

        ICaelumMasternode(_contract_token)._externalArrangeFlow();

        uint rewardAmount = _reward();
        uint rewardMasternode = _reward_masternode();

        tokensMinted += rewardAmount.add(rewardMasternode);

        uint epochCounter = _newEpoch(nonce);

        _adjustDifficulty();

        statistics = Statistics(msg.sender, rewardAmount, block.number, now);

        emit Mint(msg.sender, rewardAmount, epochCounter, challengeNumber);

        return true;
    }

    function _reward() internal returns(uint) {

        uint _pow = ICaelumMasternode(_contract_token).rewardsProofOfWork();

        ICaelumToken(_contract_token).rewardExternal(msg.sender, _pow);

        return _pow;
    }

    function _reward_masternode() internal returns(uint) {

        uint _mnReward = ICaelumMasternode(_contract_token).rewardsMasternode();
        if (ICaelumMasternode(_contract_token).masternodeCounter() == 0) return 0;

        address _mnCandidate = ICaelumMasternode(_contract_token).isPartOf(ICaelumMasternode(_contract_token).masternodeCandidate()); // userByIndex[masternodeCandidate].accountOwner;
        if (_mnCandidate == 0x0) return 0;

        ICaelumToken(_contract_token).rewardExternal(_mnCandidate, _mnReward);

        emit RewardMasternode(_mnCandidate, _mnReward);

        return _mnReward;
    }

    function getMiningReward() public view returns(uint) {
        return (baseMiningReward * 1e8).div(2 ** rewardEra);
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
        uint usercounter
    )
    {
        return ICaelumMasternode(_contract_token).contractProgress();

    }

}

// File: contracts\flattened\CaelumToken.sol

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

// File: contracts\libs\ERC20Basic.sol

//solium-disable linebreak-style
pragma solidity ^0.4.25;

contract ERC20Basic {
    function totalSupply() public view returns(uint256);

    function balanceOf(address _who) public view returns(uint256);

    function transfer(address _to, uint256 _value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\libs\ERC20.sol

//solium-disable linebreak-style
pragma solidity ^0.4.25;

contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender) public view returns(uint256);

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);

    function approve(address _spender, uint256 _value) public returns(bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts\libs\BasicToken.sol

//solium-disable linebreak-style
pragma solidity ^0.4.25;

contract BasicToken is ERC20Basic {
    using SafeMath
    for uint256;

    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

}

// File: contracts\libs\StandardToken.sol

//solium-disable linebreak-style
pragma solidity ^0.4.25;

contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns(bool) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns(uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public
    returns(bool) {
        allowed[msg.sender][_spender] = (
            allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public
    returns(bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

// File: contracts\interfaces\IRemoteFunctions.sol

interface IRemoteFunctions {
  function _externalAddMasternode(address) external;
  function _externalStopMasternode(address) external;
}

// File: contracts\interfaces\ERC20Interface.sol

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

// File: contracts\CaelumAcceptERC20.sol

contract CaelumAcceptERC20 is CaelumModifier {
    using SafeMath
    for uint;

    IRemoteFunctions public DataVault;

    address[] public tokensList;
    bool setOwnContract = true;

    struct _whitelistTokens {
        address tokenAddress;
        bool active;
        uint requiredAmount;
        uint validUntil;
        uint timestamp;
    }

    mapping(address => mapping(address => uint)) public tokens;
    mapping(address => _whitelistTokens) acceptedTokens;

    event Deposit(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);


    /**
     * @notice Allow the dev to set it's own token as accepted payment.
     * @dev Can be hardcoded in the constructor. Given the contract size, we decided to separate it.
     * @return bool
     */
    function addOwnToken() onlyOwner public returns(bool) {
        require(setOwnContract);
        addToWhitelist(this, 5000 * 1e8, 36500);
        setOwnContract = false;
        return true;
    }


    /**
     * @notice Add a new token as accepted payment method.
     * @param _token Token contract address.
     * @param _amount Required amount of this Token as collateral
     * @param daysAllowed How many days will we accept this token?
     */
    function addToWhitelist(address _token, uint _amount, uint daysAllowed) internal {
        _whitelistTokens storage newToken = acceptedTokens[_token];
        newToken.tokenAddress = _token;
        newToken.requiredAmount = _amount;
        newToken.timestamp = now;
        newToken.validUntil = now + (daysAllowed * 1 days);
        newToken.active = true;

        tokensList.push(_token);
    }

    /**
     * @dev internal function to determine if we accept this token.
     * @param _ad Token contract address
     * @return bool
     */
    function isAcceptedToken(address _ad) internal view returns(bool) {
        return acceptedTokens[_ad].active;
    }

    /**
     * @dev internal function to determine the requiredAmount for a specific token.
     * @param _ad Token contract address
     * @return bool
     */
    function getAcceptedTokenAmount(address _ad) internal view returns(uint) {
        return acceptedTokens[_ad].requiredAmount;
    }

    /**
     * @dev internal function to determine if the token is still accepted timewise.
     * @param _ad Token contract address
     * @return bool
     */
    function isValid(address _ad) internal view returns(bool) {
        uint endTime = acceptedTokens[_ad].validUntil;
        if (block.timestamp < endTime) return true;
        return false;
    }

    /**
     * @notice Returns an array of all accepted token. You can get more details by calling getTokenDetails function with this address.
     * @return array Address
     */
    function listAcceptedTokens() public view returns(address[]) {
        return tokensList;
    }

    /**
     * @notice Returns a full list of the token details
     * @param token Token contract address
     */
    function getTokenDetails(address token) public view returns(address ad, uint required, bool active, uint valid) {
        return (acceptedTokens[token].tokenAddress, acceptedTokens[token].requiredAmount, acceptedTokens[token].active, acceptedTokens[token].validUntil);
    }

    /**
     * @notice Public function that allows any user to deposit accepted tokens as collateral to become a masternode.
     * @param token Token contract address
     * @param amount Amount to deposit
     */
    function depositCollateral(address token, uint amount) public {
        require(isAcceptedToken(token), "ERC20 not authorised"); // Should be a token from our list
        require(amount == getAcceptedTokenAmount(token)); // The amount needs to match our set amount
        require(isValid(token)); // It should be called within the setup timeframe

        tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);

        require(StandardToken(token).transferFrom(msg.sender, this, amount), "error with token");
        emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);

        DataVault._externalAddMasternode(msg.sender);
    }


    /**
     * @notice Public function that allows any user to withdraw deposited tokens and stop as masternode
     * @param token Token contract address
     * @param amount Amount to withdraw
     */
    function withdrawCollateral(address token, uint amount) public {
        require(token != 0); // token should be an actual address
        require(isAcceptedToken(token), "ERC20 not authorised"); // Should be a token from our list
        require(amount == getAcceptedTokenAmount(token)); // The amount needs to match our set amount, allow only one withdrawal at a time.
        require(tokens[token][msg.sender] >= amount); // The owner must own at least this amount of tokens.

        uint amountToWithdraw = tokens[token][msg.sender];
        tokens[token][msg.sender] = 0;

        DataVault._externalStopMasternode(msg.sender);

        if (!StandardToken(token).transfer(msg.sender, amountToWithdraw)) revert("error msg");
        emit Withdraw(token, msg.sender, amountToWithdraw, amountToWithdraw);
    }

    function setDataStorage(address _masternodeContract) onlyOwner public {
        DataVault = IRemoteFunctions(_masternodeContract);
    }
}

// File: contracts\CaelumToken.sol

contract CaelumToken is CaelumAcceptERC20, StandardToken {
    using SafeMath
    for uint;

    ERC20 previousContract;

    bool public swapClosed = false;
    uint public swapCounter;

    string public symbol = "CLM";
    string public name = "Caelum Token";
    uint8 public decimals = 8;
    uint256 public totalSupply = 2100000000000000;


    address public allowedSwapAddress01;
    address public allowedSwapAddress02;

    uint swapStartedBlock;


    mapping(address => uint) manualSwaps;
    mapping(address => bool) hasSwapped;


    constructor() public {
        swapStartedBlock = now;
    }

    // TESTNET: REMOVE BEFORE LIVE !!!
    // MUST BE HARDCODED.
    function setSwap(address _t) public {
        allowedSwapAddress01 = _t;
    }

    /**
     * @dev Allow users to upgrade from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * @param _token Token the user wants to swap.
     */
    function upgradeTokens(address _token) public {
        require(!swapClosed, "Swap function is closed. Please use the manualUpgradeTokens function");
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now <= swapStartedBlock + 1 days, "Timeframe exipred, please use manualUpgradeTokens function");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {
            require(ERC20(_token).balanceOf(msg.sender) == 0);
            hasSwapped[msg.sender] = true;
            balances[msg.sender] = balances[msg.sender].add(amountToUpgrade);
            emit Transfer(this, msg.sender, amountToUpgrade);
        }
    }

    /**
     * @dev Allow users to upgrade manualy from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * Used when a user failed to swap in time.
     * Dev should manually verify the origin of these tokens before allowing it.
     * @param _token Token the user wants to swap.
     */
    function manualUpgradeTokens(address _token) public {
        require(!swapClosed, "Swap function is closed. Please use the manualUpgradeTokens function");
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now <= swapStartedBlock + 1 days, "Timeframe exipred, please use manualUpgradeTokens function");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {
            require(ERC20(_token).balanceOf(msg.sender) == 0);
            hasSwapped[msg.sender] = true;
            manualSwaps[msg.sender] = amountToUpgrade;
        }
    }

    /**
     * @dev Due to some bugs in the previous contracts, a handfull of users will
     * be unable to fully withdraw their masternodes. Owner can replace those tokens
     * who are forever locked up in the old contract with new ones.

     */
    function getLockedTokens(address _holder) public view returns(uint) {
        return CaelumAcceptERC20(this).tokens(this, _holder);
    }
    /**
     * @dev Approve a request for manual token swaps
     * @param _holder Holder The user who requests a swap.
     */
    function approveManualUpgrade(address _holder) onlyOwner public {
        balances[_holder] = balances[_holder].add(manualSwaps[_holder]);
        emit Transfer(this, _holder, manualSwaps[_holder]);
    }

    /**
     * @dev Decline a request for manual token swaps
     * @param _holder Holder The user who requests a swap.
     */
    function declineManualUpgrade(address _holder) onlyOwner public {
        delete manualSwaps[_holder];
        delete hasSwapped[_holder];
    }

    /**
     * @dev Due to some bugs in the previous contracts, a handfull of users will
     * be unable to fully withdraw their masternodes. Owner can replace those tokens
     * who are forever locked up in the old contract with new ones.

     */
    function replaceLockedTokens(address _holder) onlyOwner public {
        uint amountLocked = getLockedTokens(_holder);
        balances[_holder] = balances[_holder].add(amountLocked);
        emit Transfer(this, _holder, amountLocked);
        hasSwapped[msg.sender] = true;
    }

    /**
     * @dev Used to grant the mining contract rights to reward users.
     * As our contracts are separate, we call this function with modifier onlyMiningContract to sent out rewards.
     * @param _receiver Who receives the mining reward.
     * @param _amount What amount to reward.
     */
    function rewardExternal(address _receiver, uint _amount) onlyMiningContract external {
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(this, _receiver, _amount);
    }
}

// File: contracts\flattened\cook.sol


