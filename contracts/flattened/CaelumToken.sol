pragma solidity 0.4.25;

// File: contracts\libs\SafeMath.sol

//solium-disable linebreak-style
pragma solidity 0.4.25;

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
pragma solidity 0.4.25;

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
        require(msg.sender == _contract_miner, "Wrong sender");
        _;
    }

    modifier onlyTokenContract() {
        require(msg.sender == _contract_token, "Wrong sender");
        _;
    }

    modifier onlyMasternodeContract() {
        require(msg.sender == _contract_masternode, "Wrong sender");
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
pragma solidity 0.4.25;

contract ERC20Basic {
    function totalSupply() public view returns(uint256);

    function balanceOf(address _who) public view returns(uint256);

    function transfer(address _to, uint256 _value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\libs\ERC20.sol

//solium-disable linebreak-style
pragma solidity 0.4.25;

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
pragma solidity 0.4.25;

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
pragma solidity 0.4.25;

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

// File: contracts\CaelumVotings.sol

interface IRemoteFunctions {
  function _externalAddMasternode(address) external;
  function _externalStopMasternode(address) external;
  function isMasternodeOwner(address) external view returns (bool);
}

interface IcaelumVoting {
    function getTokenProposalDetails() external view returns(address, uint, uint, uint);
    function getExpiry() external view returns (uint);
    function getContractType () external view returns (uint);
}

contract NewTokenProposal is IcaelumVoting {

    enum VOTE_TYPE {TOKEN, TEAM}

    VOTE_TYPE public contractType = VOTE_TYPE.TOKEN;
    address contractAddress;
    uint requiredAmount;
    uint validUntil;
    uint votingDurationInDays;

    /**
     * @dev Create a new vote proposal for an ERC20 token.
     * @param _contract ERC20 contract
     * @param _amount How many tokens are required as collateral
     * @param _valid How long do we accept these tokens on the contract (UNIX timestamp)
     * @param _voteDuration How many days is this vote available
     */
    constructor(address _contract, uint _amount, uint _valid, uint _voteDuration) public {
        require(_voteDuration >= 14 && _voteDuration <= 50, "Proposed voting duration does not meet requirements");

        contractAddress = _contract;
        requiredAmount = _amount;
        validUntil = _valid;
        votingDurationInDays = _voteDuration;
    }

    /**
     * @dev Returns all details about this proposal
     */
    function getTokenProposalDetails() public view returns(address, uint, uint, uint) {
        return (contractAddress, requiredAmount, validUntil, uint(contractType));
    }

    /**
     * @dev Displays the expiry date of contract
     * @return uint Days valid
     */
    function getExpiry() external view returns (uint) {
        return votingDurationInDays;
    }

    /**
     * @dev Displays the type of contract
     * @return uint Enum value {TOKEN, TEAM}
     */
    function getContractType () external view returns (uint){
        return uint(contractType);
    }
}

contract CaelumVotings is CaelumModifier {
    using SafeMath for uint;

    enum VOTE_TYPE {TOKEN, TEAM}

    struct Proposals {
        address tokenContract;
        uint totalVotes;
        uint proposedOn;
        uint acceptedOn;
        VOTE_TYPE proposalType;
    }

    struct Voters {
        bool isVoter;
        address owner;
        uint[] votedFor;
    }

    uint MAJORITY_PERCENTAGE_NEEDED = 60;
    uint MINIMUM_VOTERS_NEEDED = 10;
    bool public proposalPending;

    mapping(uint => Proposals) public proposalList;
    mapping (address => Voters) public voterMap;
    mapping(uint => address) public voterProposals;
    uint public proposalCounter;
    uint public votersCount;
    uint public votersCountTeam;


    event NewProposal(uint ProposalID);
    event ProposalAccepted(uint ProposalID);

    function addToWhitelist(address _token, uint _amount, uint daysAllowed) internal;

    /**
     * @dev Create a new proposal.
     * @param _contract Proposal contract address
     * @return uint ProposalID
     */
    function pushProposal(address _contract) onlyOwner public returns (uint) {
        if(proposalCounter != 0)
        require (pastProposalTimeRules (), "You need to wait 90 days before submitting a new proposal.");
        require (!proposalPending, "Another proposal is pending.");

        uint _contractType = IcaelumVoting(_contract).getContractType();
        proposalList[proposalCounter] = Proposals(_contract, 0, now, 0, VOTE_TYPE(_contractType));

        emit NewProposal(proposalCounter);

        proposalCounter++;
        proposalPending = true;

        return proposalCounter.sub(1);
    }

    /**
     * @dev Internal function that handles the proposal after it got accepted.
     * This function determines if the proposal is a token or team member proposal and executes the corresponding functions.
     * @return uint Returns the proposal ID.
     */
    function handleLastProposal () internal returns (uint) {
        uint _ID = proposalCounter.sub(1);

        proposalList[_ID].acceptedOn = now;
        proposalPending = false;

        address _address;
        uint _required;
        uint _valid;
        uint _type;
        (_address, _required, _valid, _type) = getTokenProposalDetails(_ID);

        if(_type == uint(VOTE_TYPE.TOKEN)) {
            addToWhitelist(_address,_required,_valid);
        }

        emit ProposalAccepted(_ID);

        return _ID;
    }

    /**
     * @dev Rejects the last proposal after the allowed voting time has expired and it's not accepted.
     */
    function discardRejectedProposal() onlyOwner public returns (bool) {
        require(proposalPending);
        require (LastProposalCanDiscard());
        proposalPending = false;
        return (true);
    }

    /**
     * @dev Checks if the last proposal allowed voting time has expired and it's not accepted.
     * @return bool
     */
    function LastProposalCanDiscard () public view returns (bool) {

        uint daysBeforeDiscard = IcaelumVoting(proposalList[proposalCounter - 1].tokenContract).getExpiry();
        uint entryDate = proposalList[proposalCounter - 1].proposedOn;
        uint expiryDate = entryDate + (daysBeforeDiscard * 1 days);

        if (now >= expiryDate)
        return true;
    }

    /**
     * @dev Returns all details about a proposal
     */
    function getTokenProposalDetails(uint proposalID) public view returns(address, uint, uint, uint) {
        return IcaelumVoting(proposalList[proposalID].tokenContract).getTokenProposalDetails();
    }

    /**
     * @dev Returns if our 90 day cooldown has passed
     * @return bool
     */
    function pastProposalTimeRules() public view returns (bool) {
        uint lastProposal = proposalList[proposalCounter - 1].proposedOn;
        if (now >= lastProposal + 90 days)
        return true;
    }


    /**
     * @dev Allow any masternode user to become a voter.
     */
    function becomeVoter() public  {
        require (IRemoteFunctions(_contract_masternode).isMasternodeOwner(msg.sender), "User has no masternodes");
        require (!voterMap[msg.sender].isVoter, "User Already voted for this proposal");

        voterMap[msg.sender].owner = msg.sender;
        voterMap[msg.sender].isVoter = true;
        votersCount = votersCount + 1;
    }

    /**
     * @dev Allow voters to submit their vote on a proposal. Voters can only cast 1 vote per proposal.
     * If the proposed vote is about adding Team members, only Team members are able to vote.
     * A proposal can only be published if the total of votes is greater then MINIMUM_VOTERS_NEEDED.
     * @param proposalID proposalID
     */
    function voteProposal(uint proposalID) public returns (bool success) {
        require(voterMap[msg.sender].isVoter, "Sender not listed as voter");
        require(proposalID >= 0, "No proposal was selected.");
        require(proposalID <= proposalCounter, "Proposal out of limits.");
        require(voterProposals[proposalID] != msg.sender, "Already voted.");


            require(votersCount >= MINIMUM_VOTERS_NEEDED, "Not enough voters in existence to push a proposal");
            voterProposals[proposalID] = msg.sender;
            proposalList[proposalID].totalVotes++;

            if(reachedMajority(proposalID)) {
                // This is the prefered way of handling vote results. It costs more gas but prevents tampering.
                // If gas is an issue, you can comment handleLastProposal out and call it manually as onlyOwner.
                handleLastProposal();
                return true;
            }

    }

    /**
     * @dev Check if a proposal has reached the majority vote
     * @param proposalID Token ID
     * @return bool
     */
    function reachedMajority (uint proposalID) public view returns (bool) {
        uint getProposalVotes = proposalList[proposalID].totalVotes;
        if (getProposalVotes >= majority())
        return true;
    }

    /**
     * @dev Internal function that calculates the majority
     * @return uint Total of votes needed for majority
     */
    function majority () internal view returns (uint) {
        uint a = (votersCount * MAJORITY_PERCENTAGE_NEEDED );
        return a / 100;
    }

    /**
     * @dev Check if a proposal has reached the majority vote for a team member
     * @param proposalID Token ID
     * @return bool
     */
    function reachedMajorityForTeam (uint proposalID) public view returns (bool) {
        uint getProposalVotes = proposalList[proposalID].totalVotes;
        if (getProposalVotes >= majorityForTeam())
        return true;
    }

    /**
     * @dev Internal function that calculates the majority
     * @return uint Total of votes needed for majority
     */
    function majorityForTeam () internal view returns (uint) {
        uint a = (votersCountTeam * MAJORITY_PERCENTAGE_NEEDED );
        return a / 100;
    }

}

// File: contracts\CaelumAcceptERC20.sol

contract CaelumAcceptERC20 is CaelumModifier, CaelumVotings {
    using SafeMath for uint;

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

        IRemoteFunctions(_contract_masternode)._externalAddMasternode(msg.sender);
    }

    /**
     * @notice Public function that allows any user to withdraw deposited tokens and stop as masternode
     * @param token Token contract address
     * @param amount Amount to withdraw
     */
    function withdrawCollateral(address token, uint amount) public {
        require(token != 0, "N"); // token should be an actual address
        require(isAcceptedToken(token), "ERC20 not authorised"); // Should be a token from our list
        require(amount == getAcceptedTokenAmount(token)); // The amount needs to match our set amount, allow only one withdrawal at a time.
        uint amountToWithdraw = amount;
        tokens[token][msg.sender] = tokens[token][msg.sender] - amount;

        if (!StandardToken(token).transfer(msg.sender, amountToWithdraw)) revert("error msg");
        emit Withdraw(token, msg.sender, amountToWithdraw, amountToWithdraw);

        IRemoteFunctions(_contract_masternode)._externalStopMasternode(msg.sender);
    }

}

// File: contracts\CaelumToken.sol

contract CaelumToken is CaelumAcceptERC20, StandardToken {
    using SafeMath for uint;

    bool public swapClosed = false;

    string public symbol = "CLM";
    string public name = "Caelum Token";
    uint8 public decimals = 8;
    uint256 public totalSupply = 2100000000000000;

    address public allowedSwapAddress01 = 0x7600bF5112945F9F006c216d5d6db0df2806eDc6;
    address public allowedSwapAddress02 = 0x16Da16948e5092A3D2aA71Aca7b57b8a9CFD8ddb;

    uint swapStartedBlock;

    mapping(address => uint) manualSwaps;
    mapping(address => bool) hasSwapped;


    event NewSwapRequest(address _swapper, uint _amount);
    event TokenSwapped(address _swapper, uint _amount);

    function setSwap(address _t, address _b) public {
      allowedSwapAddress01 = _t;
      allowedSwapAddress02 = _b;
    }

    constructor() public {
        swapStartedBlock = now;
    }

    /**
     * @dev Allow users to upgrade from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * @param _token Token the user wants to swap.
     */
    function upgradeTokens(address _token) public {
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now <= swapStartedBlock + 1 days, "Timeframe exipred, please use manualUpgradeTokens function");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {
            require(ERC20(_token).balanceOf(msg.sender) == 0);

            if(
              ERC20(allowedSwapAddress01).balanceOf(msg.sender) == 0  &&
              ERC20(allowedSwapAddress02).balanceOf(msg.sender) == 0
            ) {
              hasSwapped[msg.sender] = true;
            }

            tokens[_token][msg.sender] = tokens[_token][msg.sender].add(amountToUpgrade);
            balances[msg.sender] = balances[msg.sender].add(amountToUpgrade);
            emit Transfer(this, msg.sender, amountToUpgrade);
            emit TokenSwapped(msg.sender, amountToUpgrade);
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
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now >= swapStartedBlock + 1 days, "Timeframe incorrect");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {
            require(ERC20(_token).balanceOf(msg.sender) == 0);
            if(
              ERC20(allowedSwapAddress01).balanceOf(msg.sender) == 0  &&
              ERC20(allowedSwapAddress02).balanceOf(msg.sender) == 0
            ) {
              hasSwapped[msg.sender] = true;
            }

            tokens[_token][msg.sender] = tokens[_token][msg.sender].add(amountToUpgrade);
            manualSwaps[msg.sender] = amountToUpgrade;
            emit NewSwapRequest(msg.sender, amountToUpgrade);
        }
    }

    /**
     * @dev Due to some bugs in the previous contracts, a handfull of users will
     * be unable to fully withdraw their masternodes. Owner can replace those tokens
     * who are forever locked up in the old contract with new ones.
     */
     function getLockedTokens(address _contract, address _holder) public view returns(uint) {
         return CaelumAcceptERC20(_contract).tokens(_contract, _holder);
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
     function replaceLockedTokens(address _contract, address _holder) onlyOwner public {
         uint amountLocked = getLockedTokens(_contract, _holder);
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
    function rewardExternal(address _receiver, uint _amount) onlyMiningContract public {
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(this, _receiver, _amount);
    }
}
