pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/PausableToken.sol";
import "zeppelin-solidity/contracts/token/CappedToken.sol";


/**
 * @title FKX
 */
contract FKX is PausableToken, CappedToken(FKX.TOKEN_SUPPLY) {

  using SafeMath for uint256;

  string public constant name = "Knoxstertoken";
  string public constant symbol = "FKX";
  uint8 public constant decimals = 18;
  string public constant version = "1.0";
  uint256 public constant TOKEN_SUPPLY  = 150000000 * (10 ** uint256(decimals)); // 150 Million FKX

  function FKX() public {
    pause(); 
  }

}
