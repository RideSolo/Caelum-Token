import "../../libs/StandardToken.sol";

contract tokenToSwap is StandardToken {
  string public symbol = "CLM";
  string public name = "Caelum Token";
  uint8 public decimals = 8;
  uint256 public totalSupply = 2100000000000000;

  constructor() {
    balances[msg.sender] = balances[msg.sender].add(420000 * 1e8);
    emit Transfer(this, msg.sender, 420000 * 1e8);
  }
}
