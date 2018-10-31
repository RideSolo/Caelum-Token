var _clmTOKEN = artifacts.require("./CaelumToken.sol");
var _clmSwapTOKEN = artifacts.require("./CaelumTokenToSwap.sol");
var _clmSwapTOKEN2 = artifacts.require("./CaelumTokenToSwap.sol");
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
    console.log("\n Swap tests \n");
    swapToken = await _clmSwapTOKEN.deployed();
    swapToken2 = await _clmSwapTOKEN2.deployed();
    mainToken = await _clmTOKEN.deployed(swapToken.address);
    clmMASTERNODE = await _clmMasternode.deployed();
  })

  // Token swap

  it('Should set the old token address on the new contract', async function() {
    let swapTokens = await mainToken.setSwap(swapToken.address, swapToken.address);
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


})
