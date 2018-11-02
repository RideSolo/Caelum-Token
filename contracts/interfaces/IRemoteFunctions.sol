interface IRemoteFunctions {
  function _externalAddMasternode(address) external;
  function _externalStopMasternode(address) external;
  function isMasternodeOwner(address) external view returns (bool);
  function userHasActiveNodes(address) external view returns (bool);
}
