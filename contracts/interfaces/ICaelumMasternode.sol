interface ICaelumMasternode {
    function _externalArrangeFlow() external;
    function rewardsProofOfWork() external returns (uint) ;
    function rewardsMasternode() external returns (uint) ;
    function masternodeCounter() external returns (uint) ;
    function masternodeCandidate() external returns (uint) ;
    function isPartOf(uint) external view returns  (address) ;
    function contractProgress() external view returns (uint, uint, uint, uint, uint, uint, uint, uint);
}
