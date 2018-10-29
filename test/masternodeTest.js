var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");
var _clmMasternode = artifacts.require("./CaelumMasternode.sol");


let catchRevert = require("./exceptions.js").catchRevert;

contract('CaelumMasternode main functions', function(accounts) {
  var swapToken
  var mainToken
  var clmMASTERNODE

  it("can deploy ", async function () {
    console.log("\n Swap tests \n");
    swapToken = await _clmSwapTOKEN.deployed();
    mainToken = await _clmTOKEN.deployed(swapToken.address);
    clmMASTERNODE = await _clmMasternode.deployed();
  })

  it('Execute swap', async function() {
    await mainToken.setSwap(swapToken.address);
    await swapToken.approve(mainToken.address, 420000 * 1e18);
    await mainToken.upgradeTokens(swapToken.address);
  });

  it('Execute preparation for depositing tokens', async function() {
    await mainToken.setMasternodeContract(clmMASTERNODE.address);
    await mainToken.setDataStorage(clmMASTERNODE.address);
    await mainToken.setMiningContract(clmMASTERNODE.address);
    await mainToken.addOwnToken();
  });

  it("Should be able to become a masternode upon depositing collateral", async function () {
    await mainToken.approve(mainToken.address, 5000 * 1e18);
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8);
    let status = await mainToken.getLockedTokens(accounts[0]);
    assert.equal  (status.valueOf(), 5000 * 1e8);
    let isOwner = await clmMASTERNODE.isMasternodeOwner(accounts[0]);
    assert.equal (isOwner, true);
  })

})
