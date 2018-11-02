interface ICaelumMasternode {
    function _externalArrangeFlow() external;
    function rewardsProofOfWork() external view returns (uint) ;
    function rewardsMasternode() external view returns (uint) ;
    function masternodeIDcounter() external view returns (uint) ;
    function masternodeCandidate() external view returns (uint) ;
    function getUserFromID(uint) external view returns  (address) ;
    function userCounter() external view returns(uint);
    function contractProgress() external view returns (uint, uint, uint, uint, uint, uint, uint, uint);
}
