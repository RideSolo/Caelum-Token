pragma solidity 0.4.25;

import "./interfaces/EIP918Interface.sol";

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
