
import "./libs/Ownable.sol";
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
        require (now <= publishedDate + 10 days);
        _contract_miner = _contract;
    }

    function setTokenContract(address _contract) onlyOwner public {
        require (now <= publishedDate + 10 days);
        _contract_token = _contract;
    }

    function setMasternodeContract(address _contract) onlyOwner public {
        require (now <= publishedDate + 10 days);
        _contract_masternode = _contract;
    }

    /**
     * Future use. If we make a voting contract, we can set this once.
     */
    function setVotingContract(address _contract) onlyOwner public {
        require (!voteContractSet);
        _contract_masternode = _contract;
        voteContractSet = true; // forever lock this
    }

    /**
     * @dev Move the voting away from token. All votes will be made from the masternodecontract
     */
    function VoteForVotingContract(address _contract) onlyVotingContract external {
        _contract_miner = _contract;
    }

    /**
     * @dev Move the voting away from token. All votes will be made from the masternodecontract
     */
    function VoteForTokenContract(address _contract) onlyVotingContract external{
        _contract_token = _contract;
    }

    /**
     * @dev Move the voting away from token. All votes will be made from the masternodecontract
     */
    function VoteForMasternodeContract(address _contract) onlyVotingContract external{
        _contract_masternode = _contract;
    }

    /**
     * @dev Move the voting away from token. All votes will be made from the masternodecontract
     * Future use only.
     */
    function VoteForMiningContract(address _contract) onlyVotingContract external{
        _contract_voting = _contract;
    }
}
