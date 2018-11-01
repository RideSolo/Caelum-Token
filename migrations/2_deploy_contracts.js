var caelumToken = artifacts.require("./CaelumToken.sol");
var caelumTokenToSwap = artifacts.require("./CaelumTokenToSwap.sol");
var caelumTokenToSwap2 = artifacts.require("./CaelumTokenToSwap2.sol");
var caelumMasternode = artifacts.require("./CaelumMasternode.sol");
var caelumMod = artifacts.require("./CaelumModifierAbstract.sol");

module.exports = function(deployer) {

  deployer.deploy(caelumTokenToSwap);
  deployer.deploy(caelumTokenToSwap2);
  deployer.deploy(caelumToken);
  deployer.deploy(caelumMasternode);
  deployer.deploy(caelumMod);
};
