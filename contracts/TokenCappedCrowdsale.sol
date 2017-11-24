pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/crowdsale/Crowdsale.sol';

/**
 * @title TokenCappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract TokenCappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public tokenCap;

  function TokenCappedCrowdsale(uint256 _tokenCap) public {
    require(_tokenCap > 0);
    tokenCap = _tokenCap;
  }

  // overriding Crowdsale#validPurchase to add extra token cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    uint256 tokens = token.totalSupply().add(msg.value.mul(rate));
    bool withinCap = tokens <= tokenCap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = token.totalSupply() >= tokenCap;
    return super.hasEnded() || capReached;
  }

}
