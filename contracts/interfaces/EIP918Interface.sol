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
