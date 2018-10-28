var caelumToken = artifacts.require("./CaelumToken.sol");
var caelumTokenToSwap = artifacts.require("./CaelumTokenToSwap.sol");
var caelumMasternode = artifacts.require("./CaelumMasternode.sol");

module.exports = function(deployer) {

  deployer.deploy(caelumTokenToSwap);
  deployer.deploy(caelumToken);
  deployer.deploy(caelumMasternode);
};
