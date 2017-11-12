pragma solidity ^0.4.13;


import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/token/BurnableToken.sol";


/**
 * @title FKX
 */
contract FKX is MintableToken, BurnableToken {

  string public constant name = "Knoxstercoin";
  string public constant symbol = "FKX";
  uint8 public constant decimals = 18;
  string public constant version = "1.0";

  uint256 public constant INITIAL_SUPPLY = 10 * (10 ** uint256(decimals)); // 10 Ether

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function FKX() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}
