pragma solidity 0.4.25;

import "./libs/StandardToken.sol";
import "./CaelumModifier.sol";

interface IcaelumVoting {
    function getTokenProposalDetails() external view returns(address, uint, uint, uint);

    function getExpiry() external view returns(uint);

    function getContractType() external view returns(uint);
}

interface IVotingAbstracts {
    function setMasternodeContractFromVote(address _t) external;

    function setTokenContractFromVote(address _t) external;

    function setMiningContractFromVote(address _t) external;

    function isMasternodeOwner(address _t) external returns(bool);

    function isTeamMember(address _t) external returns(bool);

}

contract CaelumModifierAbstract is Ownable {

    address public _contract_miner;
    address public _contract_token;
    address public _contract_masternode;
    address public _contract_voting;
    bool voteContractSet = false;
    uint public publishedDate;

    constructor() public {
        publishedDate = now;
    }

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

    modifier onlyVotingOrOwner() {
        require(msg.sender == _contract_voting || msg.sender == owner, "Wrong sender");
        _;
    }

    modifier onlyVotingContract() {
        require(msg.sender == _contract_voting || msg.sender == owner, "Wrong sender");
        _;
    }

    /**
     * All contracts can be changed by the owner up to 10 days after deployment.
     * After this timespan, contract can only be changed by a vote.
     */

    function setMiningContract(address _contract) onlyOwner public {
        require(now <= publishedDate + 10 days);
        _contract_miner = _contract;
    }

    function setTokenContract(address _contract) onlyOwner public {
        require(now <= publishedDate + 10 days);
        _contract_token = _contract;
    }

    function setMasternodeContract(address _contract) onlyOwner public {
        require(now <= publishedDate + 10 days);
        _contract_masternode = _contract;
    }

    /**
     * Future use. If we make a voting contract, we can set this once.
     */
    function setVotingContract(address _contract) onlyOwner public {
        require(!voteContractSet);
        _contract_masternode = _contract;
        voteContractSet = true; // forever lock this
    }

    /**
     * @dev Move the voting away from token. All votes will be made from the masternodecontract
     */
    function VoteForVotingContract(address _contract) onlyVotingContract internal {
        _contract_miner = _contract;
    }

    /**
     * @dev Move the voting away from token. All votes will be made from the masternodecontract
     */
    function VoteForTokenContract(address _contract) onlyVotingContract internal {
        _contract_token = _contract;
    }

    /**
     * @dev Move the voting away from token. All votes will be made from the masternodecontract
     */
    function VoteForMasternodeContract(address _contract) onlyVotingContract internal {
        _contract_masternode = _contract;
    }

    /**
     * @dev Move the voting away from token. All votes will be made from the masternodecontract
     * Future use only.
     */
    function VoteForMiningContract(address _contract) onlyVotingContract internal {
        _contract_voting = _contract;
    }


}

contract CaelumModifierVoting is CaelumModifierAbstract {
    using SafeMath
    for uint;

    enum VOTE_TYPE {
        MINER,
        MASTER,
        TOKEN,
        VOTING
    }

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
    mapping(address => Voters) public voterMap;
    mapping(uint => address) public voterProposals;
    uint public proposalCounter;
    uint public votersCount;
    uint public votersCountTeam;


    event NewProposal(uint ProposalID);
    event ProposalAccepted(uint ProposalID);

    address _CaelumMasternodeContract;
    IVotingAbstracts public MasternodeContract;

    function setMNContractForData() onlyOwner public {
        MasternodeContract = IVotingAbstracts(_contract_masternode);
        _CaelumMasternodeContract = (_contract_masternode);
    }

    function setVotingMinority(uint _total) onlyOwner public {
        require(_total > MINIMUM_VOTERS_NEEDED);
        MINIMUM_VOTERS_NEEDED = _total;
    }


    /**
     * @dev Create a new proposal.
     * @param _contract Proposal contract address
     * @return uint ProposalID
     */
    function pushProposal(address _contract) onlyOwner public returns(uint) {
        if (proposalCounter != 0)
            require(pastProposalTimeRules(), "You need to wait 90 days before submitting a new proposal.");
        require(!proposalPending, "Another proposal is pending.");

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
    function handleLastProposal() internal returns(uint) {
        uint _ID = proposalCounter.sub(1);

        proposalList[_ID].acceptedOn = now;
        proposalPending = false;

        address _address;
        uint _required;
        uint _valid;
        uint _type;
        (_address, _required, _valid, _type) = getTokenProposalDetails(_ID);

        if (_type == uint(VOTE_TYPE.MINER)) {
            VoteForMiningContract(_address);
        }

        if (_type == uint(VOTE_TYPE.MASTER)) {
            VoteForMasternodeContract(_address);
        }

        if (_type == uint(VOTE_TYPE.TOKEN)) {
            VoteForTokenContract(_address);
        }

        if (_type == uint(VOTE_TYPE.VOTING)) {
            VoteForVotingContract(_address);
        }

        emit ProposalAccepted(_ID);

        return _ID;
    }

    /**
     * @dev Rejects the last proposal after the allowed voting time has expired and it's not accepted.
     */
    function discardRejectedProposal() onlyOwner public returns(bool) {
        require(proposalPending);
        require(LastProposalCanDiscard());
        proposalPending = false;
        return (true);
    }

    /**
     * @dev Checks if the last proposal allowed voting time has expired and it's not accepted.
     * @return bool
     */
    function LastProposalCanDiscard() public view returns(bool) {

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
    function pastProposalTimeRules() public view returns(bool) {
        uint lastProposal = proposalList[proposalCounter - 1].proposedOn;
        if (now >= lastProposal + 90 days)
            return true;
    }


    /**
     * @dev Allow any masternode user to become a voter.
     */
    function becomeVoter() public {
        require(MasternodeContract.isMasternodeOwner(msg.sender), "User has no masternodes");
        require(voterMap[msg.sender].isVoter = false, "User is a voter already");
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
    function voteProposal(uint proposalID) public returns(bool success) {
        require(voterMap[msg.sender].isVoter, "Sender not listed as voter");
        require(proposalID >= 0, "No proposal was selected.");
        require(proposalID <= proposalCounter, "Proposal out of limits.");
        require(voterProposals[proposalID] != msg.sender, "Already voted.");


        require(votersCount >= MINIMUM_VOTERS_NEEDED, "Not enough voters in existence to push a proposal");
        voterProposals[proposalID] = msg.sender;
        proposalList[proposalID].totalVotes++;
        voterMap[msg.sender].isVoter = false;

        if (reachedMajority(proposalID)) {
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
    function reachedMajority(uint proposalID) public view returns(bool) {
        uint getProposalVotes = proposalList[proposalID].totalVotes;
        if (getProposalVotes >= majority())
            return true;
    }

    /**
     * @dev Internal function that calculates the majority
     * @return uint Total of votes needed for majority
     */
    function majority() internal view returns(uint) {
        uint a = (votersCount * MAJORITY_PERCENTAGE_NEEDED);
        return a / 100;
    }

}

contract InterfaceModifiers is Ownable {
    CaelumModifierAbstract _internalMod;

    function setModifierContract(address _t) {
        _internalMod = CaelumModifierAbstract(_t);
    }

    modifier onlyMiningContract() {
        require(msg.sender == _internalMod._contract_miner(), "Wrong sender");
        _;
    }

    modifier onlyTokenContract() {
        require(msg.sender == _internalMod._contract_token(), "Wrong sender");
        _;
    }

    modifier onlyMasternodeContract() {
        require(msg.sender == _internalMod._contract_masternode(), "Wrong sender");
        _;
    }

    modifier onlyVotingOrOwner() {
        require(msg.sender == _internalMod._contract_voting() || msg.sender == owner, "Wrong sender");
        _;
    }

    modifier onlyVotingContract() {
        require(msg.sender == _internalMod._contract_voting() || msg.sender == owner, "Wrong sender");
        _;
    }
}

contract NewContractProposal is IcaelumVoting {

    enum VOTE_TYPE {
        MINER,
        MASTER,
        TOKEN,
        VOTING
    }

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
