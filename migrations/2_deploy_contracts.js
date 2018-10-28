var caelumToken = artifacts.require("./CaelumToken.sol");
var caelumTokenToSwap = artifacts.require("./CaelumTokenToSwap.sol");

module.exports = function(deployer) {

  deployer.deploy(caelumTokenToSwap);
  deployer.deploy(caelumToken);
};
