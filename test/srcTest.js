var srcToken = artifacts.require("./src/token/CaelumToken.sol");
var srcTokenToSwap = artifacts.require("./src/token/tokenToSwap.sol");
var srcTokenToSwap2 = artifacts.require("./src/token/tokenToSwap2.sol");
var scrMiner = artifacts.require("./src/miner/CaelumMiner.sol");
var srcMasternode = artifacts.require("./src/masternode/CaelumMasternode.sol");
var srcModifier = artifacts.require("./src/contracts/CaelumModifierVoting.sol");

let catchRevert = require("./exceptions.js").catchRevert;

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

  it('Forward 10 days', async function() {
    await timeTravel(86400 * 10);
    await mineBlock();
  });

  it('Should fail to set the modifier contracts after 10 days', async function() {
    console.log ("\n Token functions \n");
    await catchRevert(mainToken.setModifierContract(mainModifier.address));
  });



})
