var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");
var _clmSwapTOKEN2 = artifacts.require("./CaelumTokenToSwap2.sol");
var _clmMasternode = artifacts.require("./CaelumMasternode.sol");


let catchRevert = require("./exceptions.js").catchRevert;

contract('CaelumToken main functions', function(accounts) {

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

  var swapToken
  var swapToken2
  var mainToken
  var clmMASTERNODE

  it("can deploy ", async function () {
    console.log("\n Swap tests after deploy \n");
    swapToken = await _clmSwapTOKEN.deployed();
    swapToken2 = await _clmSwapTOKEN2.deployed();
    mainToken = await _clmTOKEN.deployed(swapToken.address);
  })

  it('Should set the old token address on the new contract and move 2 days in the future', async function() {
    let swapTokens = await mainToken.setSwap(swapToken.address, swapToken2.address);

  });

  it("Should be able to swap 'swapToken' after contract deployment", async function () {
    await swapToken.approve(mainToken.address, 420000 * 1e8);
    await mainToken.upgradeTokens(swapToken.address);
  })

  it("Should fail to swap 'swapToken2' > 24h after contract deployment", async function () {
    await timeTravel(86400 * 2);
    await mineBlock();

    await swapToken2.approve(mainToken.address, 420000 * 1e8);
    await catchRevert(mainToken.upgradeTokens(swapToken2.address));
  })

  it("Should be able to apply for a manual swap for 'swapToken2'", async function () {
    await swapToken2.approve(mainToken.address, 420000 * 1e8);
    await mainToken.manualUpgradeTokens(swapToken2.address);
  })

  it("Should allow owner to approve the manual request", async function () {
    await mainToken.approveManualUpgrade(accounts[0]);
  })

  it("Should fail to swap 'swapToken' after user already swapped", async function () {
    await swapToken.approve(mainToken.address, 420000 * 1e8);
    await catchRevert(mainToken.upgradeTokens(swapToken.address));
  })

  it("Should fail to swap 'swapToken2'  after user already swapped", async function () {
    await swapToken2.approve(mainToken.address, 420000 * 1e8);
    await catchRevert(mainToken.upgradeTokens(swapToken2.address));
  })


})
