var srcToken = artifacts.require("./src/token/CaelumToken.sol");
var scrMiner = artifacts.require("./src/miner/CaelumMiner.sol");
var srcMasternode = artifacts.require("./src/masternode/CaelumMasternode.sol");
var srcModifier = artifacts.require("./src/contracts/CaelumModifierVoting.sol");

let catchRevert = require("./exceptions.js").catchRevert;

contract('Source main functions', function(accounts) {
  var mainToken
  var mainMiner
  var mainMasternode
  var mainModifier

  it("can deploy ", async function () {
    mainToken = await srcToken.deployed();
    mainMiner = await scrMiner.deployed();
    mainMasternode = await srcMasternode.deployed();
    mainModifier = await srcModifier.deployed();
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

})
