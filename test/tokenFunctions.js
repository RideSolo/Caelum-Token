var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");
var _clmMasternode = artifacts.require("./CaelumMasternode.sol");

let catchRevert = require("./exceptions.js").catchRevert;

contract('CaelumToken main functions', function(accounts) {
  var swapToken
  var mainToken
  var clmMASTERNODE

  it("can deploy ", async function () {
    swapToken = await _clmSwapTOKEN.deployed();
    mainToken = await _clmTOKEN.deployed(swapToken.address);
    clmMASTERNODE = await _clmMasternode.deployed();
  })

  it('Execute swap', async function() {
    await clmMASTERNODE.setTokenContract(mainToken.address);
    await mainToken.setMasternodeContract(clmMASTERNODE.address);
    await mainToken.setMiningContract(clmMASTERNODE.address);
    await mainToken.setSwap(swapToken.address, swapToken.address);
    await swapToken.approve(mainToken.address, 420000 * 1e18);
    await mainToken.upgradeTokens(swapToken.address);
  });

  it('Execute collateral deposit for deposit/withdraw test', async function() {

    await mainToken.addOwnToken();
    await mainToken.approve(mainToken.address, 5000 * 1e18);
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8);
  });


  it("Should have 5000 tokens locked in the contract", async function () {
      let status = await mainToken.getLockedTokens(mainToken.address, accounts[0]);
      assert.equal  (status.valueOf(), 5000 * 1e8);
  })

  it("Should allow withdrawal of 5000 tokens and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8);
      let status = await clmMASTERNODE.userHasActiveNodes(accounts[0]);
      assert.equal  (status.valueOf(), false);
  })

  it("Should have 0 tokens locked in the contract", async function () {
      let status = await mainToken.getLockedTokens(mainToken.address, accounts[0]);
      assert.equal  (status.valueOf(), 0 * 1e8);
  })

  it("Should have 420.000 tokens on the new contract", async function () {
    let getBalance = await mainToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 420000 *1e8);
  })

  it('Execute collateral deposit for locked tokens tests', async function() {
    await mainToken.approve(mainToken.address, 5000 * 1e18);
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8);
  });

  it("Should have 5000 tokens locked in the contract", async function () {
      let status = await mainToken.getLockedTokens(mainToken.address, accounts[0]);
      assert.equal  (status.valueOf(), 5000 * 1e8);
  })

  it("Should allow owner to replace the tokens now locked in the contract", async function () {
      await mainToken.replaceLockedTokens(mainToken.address, accounts[0]);
  })

  it('Account 0 should now have the new tokens as balance', async function() {
    let getBalance = await mainToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 420000 * 1e8);
  });


})
