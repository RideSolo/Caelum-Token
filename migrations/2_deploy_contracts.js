var caelumToken = artifacts.require("./CaelumToken.sol");
var caelumTokenToSwap = artifacts.require("./CaelumTokenToSwap.sol");
var caelumTokenToSwap2 = artifacts.require("./CaelumTokenToSwap2.sol");
var caelumMasternode = artifacts.require("./CaelumMasternode.sol");
// src
var srcToken = artifacts.require("./src/token/CaelumToken.sol");
var scrMiner = artifacts.require("./src/miner/CaelumMiner.sol");
var srcMasternode = artifacts.require("./src/masternode/CaelumMasternode.sol");
var srcModifier = artifacts.require("./src/contracts/CaelumModifierVoting.sol");

module.exports = function(deployer) {

  deployer.deploy(caelumTokenToSwap);
  deployer.deploy(caelumTokenToSwap2);
  deployer.deploy(caelumToken);
  deployer.deploy(caelumMasternode);
  //
  deployer.deploy(srcToken);
  deployer.deploy(scrMiner);
  deployer.deploy(srcMasternode);
  deployer.deploy(srcModifier);
};
