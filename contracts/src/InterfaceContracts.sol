import "../libs/Ownable.sol";

contract InterfaceContracts is Ownable {
    InterfaceContracts public _internalMod;

    function setModifierContract (address _t) {
        _internalMod = InterfaceContracts(_t);
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

      function _contract_voting () public view returns (address) {
        return _internalMod._contract_voting();
    }

    function _contract_masternode () public view returns (address) {
        return _internalMod._contract_masternode();
    }

    function _contract_token () public view returns (address) {
        return _internalMod._contract_token();
    }

    function _contract_miner () public view returns (address) {
        return _internalMod._contract_miner();
    }
}
