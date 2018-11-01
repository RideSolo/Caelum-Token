var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");
var _clmMasternode = artifacts.require("./CaelumMasternode.sol");
var caelumMod = artifacts.require("./CaelumModifierAbstract.sol");


let catchRevert = require("./exceptions.js").catchRevert;

contract('CaelumMasternode main functions', function(accounts) {
  var swapToken
  var mainToken
  var clmMASTERNODE
  var clmMod

  it("can deploy ", async function () {
    console.log("\n General masternode tests \n");
    swapToken = await _clmSwapTOKEN.deployed();
    mainToken = await _clmTOKEN.deployed();
    clmMASTERNODE = await _clmMasternode.deployed();
    clmMod = await caelumMod.deployed();
  })

  it('Set modifier', async function() {
    await mainToken.setModifierContract(clmMod.address);
    await clmMASTERNODE.setModifierContract(clmMod.address);
    await clmMod.setTokenContract(mainToken.address);
    await clmMod.setMasternodeContract(clmMASTERNODE.address);
    await clmMod.setMiningContract(clmMASTERNODE.address);
  });

});
