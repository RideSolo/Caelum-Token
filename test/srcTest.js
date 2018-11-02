var srcToken = artifacts.require("./src/token/CaelumToken.sol");
var srcTokenToSwap = artifacts.require("./src/token/tokenToSwap.sol");
var srcTokenToSwap2 = artifacts.require("./src/token/tokenToSwap2.sol");
var scrMiner = artifacts.require("./src/miner/CaelumMiner.sol");
var srcMasternode = artifacts.require("./src/masternode/CaelumMasternode.sol");
var srcModifier = artifacts.require("./src/contracts/CaelumModifierVoting.sol");

let catchRevert = require("./exceptions.js").catchRevert;

/**
contract('Source main functions', function(accounts) {
  var mainToken
  var mainSwapToken
  var mainSwapToken2
  var mainMiner
  var mainMasternode
  var mainModifier

  const timeTravel = function (time) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], // 86400 is num seconds in day
      id: new Date().getTime()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  })
}

  const mineBlock = function () {
    return new Promise((resolve, reject) => {
      web3.currentProvider.sendAsync({
        jsonrpc: "2.0",
        method: "evm_mine"
      }, (err, result) => {
        if(err){ return reject(err) }
        return resolve(result)
      });
    })
  }

  it("can deploy ", async function () {
    mainToken = await srcToken.deployed();
    mainMiner = await scrMiner.deployed();
    mainMasternode = await srcMasternode.deployed();
    mainModifier = await srcModifier.deployed();
    mainSwapToken = await srcTokenToSwap.deployed();
    mainSwapToken2 = await srcTokenToSwap2.deployed();

    console.log(mainSwapToken.address + " - " + mainSwapToken2.address)
  })

  it('Execute contract setting', async function() {
    //await clmMASTERNODE.setTokenContract(mainToken.address);
    await mainModifier.setMasternodeContract(mainMasternode.address);
    await mainModifier.setMiningContract(mainMiner.address);
    await mainModifier.setTokenContract(mainToken.address);
  });

  it('Set Masternode contract to use the modifier contract', async function() {
    await mainMasternode.setModifierContract(mainModifier.address);
  });

  it('Set Token contract to use the modifier contract', async function() {
    await mainToken.setModifierContract(mainModifier.address);
  });

  it('Set Miner contract to use the modifier contract', async function() {
    await mainMiner.setModifierContract(mainModifier.address);
  });

  it('Execute swap with mainSwapToken', async function() {
    console.log ("\n Swap functions \n");
    await mainToken.setSwap(mainSwapToken.address, mainSwapToken2.address);
    await mainSwapToken.approve(mainToken.address, 420000 * 1e8);
    await mainToken.upgradeTokens(mainSwapToken.address);
  });

  it('Account 0 should now have 420.000 new tokens as balance', async function() {
    let getBalance = await mainToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 420000 * 1e8);
  });

  it('Account 0 should now have 0 old tokens as balance', async function() {
    let getBalance = await mainSwapToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 0);

  });

  it('Forward 10 days', async function() {

    await timeTravel(86400 * 10);
    await mineBlock();
  });

  it('Should fail to execute swap with mainSwapToken2 after 24h', async function() {
    await mainSwapToken2.approve(mainToken.address, 420000 * 1e8);
    await catchRevert(mainToken.upgradeTokens(mainSwapToken2.address));
  });

  it('Should be able to request a manual token upgrade for 420.000 CLM', async function() {
    await mainToken.manualUpgradeTokens(mainSwapToken2.address);
  });

  it('Should allow owner to decline a manual request', async function() {
    await mainToken.declineManualUpgrade(mainSwapToken2.address, accounts[0]);
  });

  it('Account 0 should now have the old tokens back', async function() {
    let getBalance = await mainSwapToken2.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 420000 * 1e8);
  });

  it('Should allow owner to accept a manual request', async function() {
    await mainSwapToken2.approve(mainToken.address, 420000 * 1e8);
    await mainToken.manualUpgradeTokens(mainSwapToken2.address);
    await mainToken.approveManualUpgrade(accounts[0]);
  });

  it('Account 0 should now have 0 old tokens as balance', async function() {
    let getBalance = await mainSwapToken2.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 0);
  });

  it('Account 0 should now have 840.000 new tokens as balance', async function() {
    let getBalance = await mainToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 840000 * 1e8);
  });

  it('Should fail to set the modifier contracts after 10 days', async function() {
    console.log ("\n Token functions \n");
    await catchRevert(mainToken.setModifierContract(mainModifier.address));
  });


})
*/
// second

contract('Source main functions', function(accounts) {
  var mainToken
  var mainSwapToken
  var mainSwapToken2
  var mainMiner
  var mainMasternode
  var mainModifier

  const timeTravel = function (time) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], // 86400 is num seconds in day
      id: new Date().getTime()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  })
}

  const mineBlock = function () {
    return new Promise((resolve, reject) => {
      web3.currentProvider.sendAsync({
        jsonrpc: "2.0",
        method: "evm_mine"
      }, (err, result) => {
        if(err){ return reject(err) }
        return resolve(result)
      });
    })
  }

  it("can deploy ", async function () {
    mainToken = await srcToken.deployed();
    mainMiner = await scrMiner.deployed();
    mainMasternode = await srcMasternode.deployed();
    mainModifier = await srcModifier.deployed();
    mainSwapToken = await srcTokenToSwap.deployed();
    mainSwapToken2 = await srcTokenToSwap2.deployed();

    console.log(mainSwapToken.address + " - " + mainSwapToken2.address)
  })

  it('Execute contract setting', async function() {
    //await clmMASTERNODE.setTokenContract(mainToken.address);
    await mainModifier.setMasternodeContract(mainMasternode.address);
    await mainModifier.setMiningContract(mainMiner.address);
    await mainModifier.setTokenContract(mainToken.address);
  });

  it('Set Masternode contract to use the modifier contract', async function() {
    await mainMasternode.setModifierContract(mainModifier.address);
  });

  it('Set Token contract to use the modifier contract', async function() {
    await mainToken.setModifierContract(mainModifier.address);
  });

  it('Set Miner contract to use the modifier contract', async function() {
    await mainMiner.setModifierContract(mainModifier.address);
  });

  it('Execute swap with mainSwapToken', async function() {
    console.log ("\n Swap functions \n");
    await mainToken.setSwap(mainSwapToken.address, mainSwapToken2.address);
    await mainSwapToken.approve(mainToken.address, 420000 * 1e8);
    await mainToken.upgradeTokens(mainSwapToken.address);
  });

  it('Account 0 should now have 420.000 new tokens as balance', async function() {
    let getBalance = await mainToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 420000 * 1e8);
  });

  it('Account 0 should now have 0 old tokens as balance', async function() {
    let getBalance = await mainSwapToken.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 0);

  });

  it('Forward 10 days', async function() {

    await timeTravel(86400 * 10);
    await mineBlock();
  });

  it('Should fail to execute swap with mainSwapToken2 after 24h', async function() {
    await mainSwapToken2.approve(mainToken.address, 420000 * 1e8);
    await catchRevert(mainToken.upgradeTokens(mainSwapToken2.address));
  });

  it('Should be able to request a manual token upgrade for 420.000 CLM', async function() {
    await mainToken.manualUpgradeTokens(mainSwapToken2.address);
  });

  it('Should allow owner to decline a manual request', async function() {
    await mainToken.declineManualUpgrade(mainSwapToken2.address, accounts[0]);
  });

  it('Account 0 should now have the old tokens back', async function() {
    let getBalance = await mainSwapToken2.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 420000 * 1e8);
  });

  it('Account 0 should be able to request a partial swap', async function() {
    await mainSwapToken2.approve(mainToken.address, 420000 * 1e8);
    await mainToken.manualUpgradePartialTokens(mainSwapToken2.address, 400000 * 1e8);
  });

  it('Should allow owner to accept a manual request', async function() {
    await mainToken.approveManualUpgrade(accounts[0]);
  });

  it('Account 0 should now have 20.000 old tokens as balance', async function() {
    let getBalance = await mainSwapToken2.balanceOf.call(accounts[0]);
    assert.equal  (getBalance.valueOf(), 20000 * 1e8);
  });



})
