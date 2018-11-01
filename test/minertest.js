var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");
var _clmSwapTOKEN2 = artifacts.require("./CaelumTokenToSwap.sol");
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

  it('Execute preparation for mining', async function() {
    await clmMASTERNODE.setTokenContract(mainToken.address);
    await mainToken.setMasternodeContract(clmMASTERNODE.address);
    await mainToken.setMiningContract(clmMASTERNODE.address);
    await mainToken.addOwnToken();
  });
})
