pragma solidity ^0.4.25;

import "./libs/Ownable.sol";

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
