var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");
var _clmMasternode = artifacts.require("./CaelumMasternode.sol");


let catchRevert = require("./exceptions.js").catchRevert;

contract('CaelumToken main functions', function(accounts) {
  var swapToken
  var mainToken
  var clmMASTERNODE

  it("can deploy ", async function () {
    console.log("\n Swap tests \n");
    swapToken = await _clmSwapTOKEN.deployed();
    mainToken = await _clmTOKEN.deployed(swapToken.address);
    clmMASTERNODE = await _clmMasternode.deployed();
  })

  // Token swap

  it('Should set the old token address on the new contract', async function() {
    let swapTokens = await mainToken.setSwap(swapToken.address);
    //assert.ok(swapTokens);
  });

  it("Should have 420.000 tokens on the old contract", async function () {
    let getBalance = await swapToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 420000 *1e8);
  })

  it("Should not have any tokens on the new contract", async function () {
    let getBalance = await mainToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 0);
  })

  it('Should be able to approve account to spend 420.000 tokens from old contract', async function() {
    let callApprove = await swapToken.approve(mainToken.address, 420000 * 1e18);
    assert.ok(callApprove);
  });

  it('Verify if new contract has allowance on old token contract', async function() {
    let allowance = await swapToken.allowance(accounts[0], mainToken.address);
    assert.equal(allowance, 420000 * 1e18);
  });

  it('Account 0 should now should be able to swap the entire balance to token contract', async function() {
    let swapTokens = await mainToken.upgradeTokens(swapToken.address);
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


  // Balance 0.



  it('Owner should be able to set the masternode contract', async function() {
    await mainToken.setMasternodeContract(clmMASTERNODE.address);
  });

  it('Owner should be able to set the token contract', async function() {
    await mainToken.setMiningContract(clmMASTERNODE.address);
  });

  it('Owner should be able to set the token contract on masternode', async function() {
    await clmMASTERNODE.setTokenContract(mainToken.address);
    let getAddress =  await clmMASTERNODE._contract_token();
    assert.equal  (getAddress, mainToken.address);
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
    console.log("\n Test Deposit/Withdraw \n");
    let callApprove = await mainToken.approve(mainToken.address, 5000 * 1e18);
    assert.ok(callApprove);
  });

  it('Verify if new contract has allowance on old token contract', async function() {
    let allowance = await mainToken.allowance(accounts[0], mainToken.address);
    assert.equal(allowance, 5000 * 1e18);
  });

  it('Account 0 should now be able to deposit a collateral and become a masternode', async function() {
    let doDeposit = await mainToken.depositCollateral(mainToken.address, 5000 * 1e8);
    //let status = await clmMASTERNODE.userHasActiveNodes(accounts[0]);
    //assert.equal  (status.valueOf(), true, "Wrong account returned.");
  });

  it("Should have 5000 tokens locked in the contract", async function () {
      let status = await mainToken.getLockedTokens(accounts[0]);
      assert.equal  (status.valueOf(), 5000 * 1e8);
  })

  it("Should allow withdrawal of 5000 tokens and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8);
      let status = await clmMASTERNODE.userHasActiveNodes(accounts[0]);
      assert.equal  (status.valueOf(), false);
  })

  it("Should have 0 tokens locked in the contract", async function () {
      let status = await mainToken.getLockedTokens(accounts[0]);
      assert.equal  (status.valueOf(), 0 * 1e8);
  })


  it("should fail to deposit an incorrect token amount (4999)", async function() {
      console.log("\n Verify security rules \n");
      await mainToken.approve(mainToken.address, 5000 * 1e18);
      await catchRevert(mainToken.depositCollateral(mainToken.address, 4999 * 1e8));
  });

})
