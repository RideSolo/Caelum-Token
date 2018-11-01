var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");
var _clmMasternode = artifacts.require("./CaelumMasternode.sol");
var caelumMod = artifacts.require("./CaelumModifierAbstract.sol");
var caelumVote = artifacts.require("./CaelumModifierVoting.sol");
var caelumProposal= artifacts.require("./NewContractProposal.sol");


let catchRevert = require("./exceptions.js").catchRevert;

contract('CaelumMasternode main functions', function(accounts) {
  var swapToken
  var mainToken
  var clmMASTERNODE
  var clmMod
  var clmVote
  var clmPropose

  it("can deploy ", async function () {
    console.log("\n General masternode tests \n");
    swapToken = await _clmSwapTOKEN.deployed();
    mainToken = await _clmTOKEN.deployed();
    clmMASTERNODE = await _clmMasternode.deployed();
    clmMod = await caelumMod.deployed();
    //clmVote = await caelumVote.deployed();
    //clmPropose = await caelumProposal.deployed(swapToken.address, 0,0,20);
  })

  it('Set modifier', async function() {
    await mainToken.setModifierContract(clmMod.address);
    await clmMASTERNODE.setModifierContract(clmMod.address);
    await clmMod.setTokenContract(mainToken.address);
    await clmMod.setMasternodeContract(clmMASTERNODE.address);
    await clmMod.setMiningContract(clmMASTERNODE.address);
  });

  it('Execute swap', async function() {
    await mainToken.setSwap(swapToken.address, swapToken.address);
    await swapToken.approve(mainToken.address, 420000 * 1e18);
    await mainToken.upgradeTokens(swapToken.address);
  });

  it('Execute collateral deposit for deposit/withdraw test', async function() {
    await mainToken.approve(mainToken.address, 5000 * 1e18);
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8);
  });

});
