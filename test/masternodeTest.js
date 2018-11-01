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

  it('Execute swap', async function() {
    await mainToken.setSwap(swapToken.address, swapToken.address);
    await swapToken.approve(mainToken.address, 420000 * 1e8);
    await mainToken.upgradeTokens(swapToken.address);
  });

  it('Send 10k tokens to 5 other accounts for testing', async function() {
    await mainToken.transfer(accounts[1], 10000 * 1e8);
    await mainToken.transfer(accounts[2], 10000 * 1e8);
    await mainToken.transfer(accounts[3], 10000 * 1e8);
    await mainToken.transfer(accounts[4], 10000 * 1e8);
    await mainToken.transfer(accounts[5], 10000 * 1e8);
    let getBalance = await mainToken.balanceOf.call(accounts[5]);
    assert.equal  (getBalance.valueOf(), 10000 * 1e8);
  });

  it('Execute preparation for depositing tokens', async function() {
    //await clmMASTERNODE.setTokenContract(mainToken.address);
    //await mainToken.setMasternodeContract(clmMASTERNODE.address);
    //await mainToken.setMiningContract(clmMASTERNODE.address);
    //await mainToken.addOwnToken();
  });

  it("Should be able to become a masternode upon depositing collateral [account 0 - MN 1]", async function () {
    await mainToken.approve(mainToken.address, 5000 * 1e8);
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8);
  })

  it("Should be able to become a masternode upon depositing collateral [account 0 - MN 2]", async function () {
    await mainToken.approve(mainToken.address, 5000 * 1e8);
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8);
  })

  it("Should be able to become a masternode upon depositing collateral [account 1 - MN 1]", async function () {
    await mainToken.approve(mainToken.address, 5000 * 1e8, {from: accounts[1]});
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8, {from: accounts[1]});
  })

  it("Should be able to become a masternode upon depositing collateral [account 1 - MN 2]", async function () {
    await mainToken.approve(mainToken.address, 5000 * 1e8, {from: accounts[1]});
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8, {from: accounts[1]});
  })

  it("Should return active nodes for account 0", async function () {
      let nodes = await clmMASTERNODE.userHasActiveNodes(accounts[0]);
      assert.equal(nodes, true);
  })

  it("Should return active nodes for account 1", async function () {
      let nodes = await clmMASTERNODE.userHasActiveNodes(accounts[1]);
      assert.equal(nodes, true);
  })

  it("Should allow withdrawal of [account 0 - MN2] and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8);
  })

  it("Should allow withdrawal of [account 1 - MN2] and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8, {from: accounts[1]});
  })

  it("Should allow withdrawal of [account 0 - MN1] and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8);
  })

  it("Should allow withdrawal of [account 1 - MN1] and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8, {from: accounts[1]});
  })

  it("Should return no active nodes for account 0", async function () {
      let nodes = await clmMASTERNODE.userHasActiveNodes(accounts[0]);
      assert.equal(nodes, false);
  })

  it("Should return no active nodes for account 1", async function () {
      let nodes = await clmMASTERNODE.userHasActiveNodes(accounts[1]);
      assert.equal(nodes, false);
  })

  it("Should be able to become a masternode upon depositing collateral [account 0 - MN 1]", async function () {
    console.log("\n test for genesis accounts \n");
    await clmMASTERNODE.addGenesis();
  })

  it("Should return active nodes for account 2", async function () {
      let nodes = await clmMASTERNODE.userHasActiveNodes(accounts[1]);
      assert.equal(nodes, true);
  })

  it("Should be able to become a masternode upon depositing collateral [account 1 - MN 1]", async function () {
    await mainToken.approve(mainToken.address, 5000 * 1e8, {from: accounts[1]});
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8, {from: accounts[1]});
  })

  it("Should be able to become a masternode upon depositing collateral [account 1 - MN 2]", async function () {
    await mainToken.approve(mainToken.address, 5000 * 1e8, {from: accounts[1]});
    await mainToken.depositCollateral(mainToken.address, 5000 * 1e8, {from: accounts[1]});
  })

  it("Should have 10k tokens locked in the contract", async function () {
      let status = await mainToken.getLockedTokens(mainToken.address,accounts[1]);
      assert.equal  (status.valueOf(), 10000 * 1e8);
  })

  it("Should allow withdrawal of [account 1 - MN1] and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8, {from: accounts[1]});
  })

  it("Should allow withdrawal of [account 1 - MN1] and stop this masternode", async function () {
      await mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8, {from: accounts[1]});
  })

  it("Should fail to withdraw the last masternode since it's a genesis one", async function () {
    await catchRevert( mainToken.withdrawCollateral(mainToken.address, 5000 * 1e8, {from: accounts[1]}));
  })

  it("Should fail to deposit tokens without allowance", async function () {
    await catchRevert(mainToken.depositCollateral(mainToken.address, 5000 * 1e8));
  })

  it("Should fail to deposit tokens with incorrect amount (4999)", async function () {
    await mainToken.approve(mainToken.address, 5000 * 1e8);
    await catchRevert(mainToken.depositCollateral(mainToken.address, 4999 * 1e8));
  })

  it("Should fail to deposit tokens not approved tokens", async function () {
    await mainToken.approve(swapToken.address, 5000 * 1e8);
    await catchRevert(mainToken.depositCollateral(swapToken.address, 5000 * 1e8));
  })

})
