pragma solidity ^0.4.11;


import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/token/BurnableToken.sol";
import "zeppelin-solidity/contracts/token/PausableToken.sol";


/**
 * @title FKX
 */
contract FKX is BurnableToken, PausableToken, MintableToken {

  string public constant name = "Knoxstertoken";
  string public constant symbol = "FKX";
  uint8 public constant decimals = 18;
  string public constant version = "1.0";

  /**
  * @dev Override MintableToken.finishMinting() to add canMint modifier
  */
  function finishMinting() onlyOwner canMint public returns(bool) {
      return super.finishMinting();
  }


}
