var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");


let catchRevert = require("./exceptions.js").catchRevert;

contract('CaelumToken main functions', function(accounts) {
  var swapToken
  var mainToken

  it("can deploy ", async function () {
    console.log("\n Swap tests \n");
    swapToken = await _clmSwapTOKEN.deployed();
    mainToken = await _clmTOKEN.deployed();
  })

  // Token swap

  it('Should set the old token address on the new contract', async function() {
    let swapTokens = await mainToken.setSwapAddress(swapToken.address);
    assert.ok(swapTokens);
  });

  it("Should have 420.000 tokens on the old contract", async function () {
    let getBalance = await swapToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 420000 *1e8);
  })

  it("Should not have any tokens on the new contract", async function () {
    let getBalance = await mainToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 0);
  })

  it('Should be able to approve account to spend 20.000 tokens from old contract', async function() {
    let callApprove = await swapToken.approve(mainToken.address, 20000 * 1e18);
    assert.ok(callApprove);
  });

  it('Verify if new contract has allowance on old token contract', async function() {
    let allowance = await swapToken.allowance(accounts[0], mainToken.address);
    assert.equal(allowance, 20000 * 1e18);
  });

  it('Account 0 should now should be able to swap 10 tokens to masternode contract', async function() {
    let swapTokens = await mainToken.upgradeTokens();
    assert.ok(swapTokens);
  });

  it('Account 0 should now have 420.000 new tokens as balance', async function() {
    let getBalance = await mainToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 420000 * 1e8);
  });

  it('Account 0 should now have 0 old tokens as balance', async function() {
    let getBalance = await swapToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 0);
  });

  // masternode

  it('Owner should be able to set the remote masternode contract', async function() {
    console.log("\n Masternode tests \n");
    await mainToken.setDataStorage(clmMASTERNODE.address);
    let getAddress =  await mainToken.DataVault();
    assert.equal  (getAddress, clmMASTERNODE.address);
  });

  it('Owner should be able to set the token contract', async function() {
    await mainToken.setMiningContract(clmMASTERNODE.address);
  });

  it('Owner should be able to add our own token to the allowed tokenlist', async function() {
    await mainToken.addOwnToken();
    let getListed = await mainToken.listAcceptedTokens();
    assert.equal(getListed[0], mainToken.address);
  });

  it("Should return all details about CLM token that we just added", async function () {
      let status = await mainToken.getTokenDetails(mainToken.address);
      assert.equal  (status[0].valueOf(), mainToken.address, "Wrong account returned.");
      assert.equal  (status[1].valueOf(), 5000 * 1e8, "Wrong account returned.");
  })

  it('Should be able to approve account to spend 5.000 tokens from old contract', async function() {
    console.log("\n First run \n");
    let callApprove = await mainToken.approve(mainToken.address, 5000 * 1e18);
    assert.ok(callApprove);
  });

  it('Verify if new contract has allowance on old token contract', async function() {
    let allowance = await mainToken.allowance(accounts[0], mainToken.address);
    assert.equal(allowance, 5000 * 1e18);
  });

  it('Account 0 should now be able to deposit a collateral and become a masternode', async function() {
    let doDeposit = await mainToken.depositCollateral(mainToken.address, 5000 * 1e8);
    let status = await clmMASTERNODE.userHasActiveNodes(accounts[0]);
    assert.equal  (status.valueOf(), true, "Wrong account returned.");
  });

  it("Should allow withdrawal of 5000 tokens and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8);
      let status = await clmMASTERNODE.userHasActiveNodes(accounts[0]);
      assert.equal  (status.valueOf(), false);
  })

  it('Should be able to approve account to spend 5.000 tokens from old contract', async function() {
    console.log("\n second run \n");
    let callApprove = await mainToken.approve(mainToken.address, 5000 * 1e18);
    assert.ok(callApprove);
  });

  it('Verify if new contract has allowance on old token contract', async function() {
    let allowance = await mainToken.allowance(accounts[0], mainToken.address);
    assert.equal(allowance, 5000 * 1e18);
  });

  it('Account 0 should now be able to deposit a collateral and become a masternode', async function() {
    let doDeposit = await mainToken.depositCollateral(mainToken.address, 5000 * 1e8);
    let status = await clmMASTERNODE.userHasActiveNodes(accounts[0]);
    assert.equal  (status.valueOf(), true, "Wrong account returned.");
  });

  it("Should allow withdrawal of 5000 tokens and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8);
      let status = await clmMASTERNODE.userHasActiveNodes(accounts[0]);
      assert.equal  (status.valueOf(), false);
  })

  it("should fail to deposit an incorrect token amount (4999)", async function() {
      console.log("\n Verify security rules \n");
      await mainToken.approve(mainToken.address, 5000 * 1e18);
      await catchRevert(mainToken.depositCollateral(mainToken.address, 4999 * 1e8));
  });

  it("should fail to deposit non-allowed tokens", async function() {
      await mainToken.approve(swapToken2.address, 5000 * 1e18);
      await catchRevert(mainToken.depositCollateral(swapToken2.address, 5000 * 1e8));
  });

})
