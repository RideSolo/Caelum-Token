var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");
var _clmSwapTOKEN2 = artifacts.require("./CaelumTokenToSwap2.sol");
var _clmMasternode = artifacts.require("./CaelumMasternode.sol");


let catchRevert = require("./exceptions.js").catchRevert;

contract('CaelumToken main functions', function(accounts) {
  var swapToken
  var swapToken2
  var mainToken
  var clmMASTERNODE

  it("can deploy ", async function () {
    console.log("\n Swap tests \n");
    swapToken = await _clmSwapTOKEN.deployed();
    swapToken2 = await _clmSwapTOKEN2.deployed();
    mainToken = await _clmTOKEN.deployed(swapToken.address);
    clmMASTERNODE = await _clmMasternode.deployed();
  })


  it('Should set the old token address on the new contract', async function() {
    let swapTokens = await mainToken.setSwap(swapToken.address, swapToken2.address);
  });

  it("Should be able to swap swapToken", async function () {
    await swapToken.approve(mainToken.address, 420000 * 1e8);
    await mainToken.upgradeTokens(swapToken.address);
  })

  it("Should be able to swap swapToken2", async function () {
    await swapToken2.approve(mainToken.address, 420000 * 1e8);
    await mainToken.upgradeTokens(swapToken2.address);
  })


})
