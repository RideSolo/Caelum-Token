pragma solidity 0.4.25;

import "./CaelumAcceptERC20.sol";
import "./libs/StandardToken.sol";

contract CaelumTokenToSwap is CaelumAcceptERC20, StandardToken {
    using SafeMath for uint;


    string public symbol = "CLMdd";
    string public name = "Caelum Token";
    uint8 public decimals = 8;
    uint256 public totalSupply = 2100000000000000;


    constructor() {
      balances[msg.sender] = balances[msg.sender].add(420000 * 1e8); // 2% Premine as determined by the community meeting.
        emit Transfer(this, msg.sender, 420000 * 1e8);
    }


}
