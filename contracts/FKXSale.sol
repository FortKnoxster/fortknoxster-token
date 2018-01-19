pragma solidity ^0.4.18;

import "./FKX.sol";
import "./FKXTokenTimeLock.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title FKXSale
 * @dev The FKX crowdsale based
 * Inheritance:
 * TokenCappedCrowdsale - sets a max boundary in FKX token for raised funds (from zeppelin-solidity's CappedCrowdsale.sol)
 * FinalizableCrowdsale - makes the crowdsale finalizable
 *
 */
contract FKXSale is Ownable {

  using SafeMath for uint256;

  uint256 public constant DECIMALS = 18;

  uint256 public constant TOKEN_CAP = 135000000 * (10 ** uint256(DECIMALS)); // 135 Million FKX

  FKX public token;

  FKXTokenTimeLock public tokenLock;

  function FKXSale(FKX _fkxToken) public {

    token =  _fkxToken;

    tokenLock = new FKXTokenTimeLock(token);

  }

  /**
  * @dev Finalizes the crowdsale
  */
  function finalization() public onlyOwner {
    token.finishMinting();
  }

  /**
    * @dev Pause the FKX token.
    */
  function pauseTokens() public onlyOwner {
    token.pause();
  }

  /**
   * @dev Unpause the FKX token.
   */
  function unpauseTokens() public onlyOwner {
    token.unpause();
  }


  // 
  /**
  * @dev Allocates tokens to early-bird contributors.
  * @param beneficiary wallet
  * @param baseTokens amount of tokens to be received by beneficiary
  * @param bonusTokens amount of tokens to be locked up to beneficiary
  * @param releaseTime when to unlock bonus tokens
  */
  function mintTokens(address beneficiary, uint256 baseTokens, uint256 bonusTokens, uint256 releaseTime) public onlyOwner {
    require(beneficiary != 0x0);
    require(baseTokens > 0);
    require(bonusTokens > 0);
    require(releaseTime > now);
    uint256 tokens = baseTokens.add(bonusTokens);
    uint256 newTokens =  token.totalSupply().add(tokens);                                 
    require(newTokens <= TOKEN_CAP);

    //uint256 releaseTime = now + timeDays * 1 minutes; // Change minutes to days before live deployment
    
    // Mint base tokens to beneficiary
    token.mint(beneficiary, baseTokens);

    // Mint beneficiary's bonus tokens to the token time lock
    token.mint(tokenLock, bonusTokens);

    // Time lock the tokens
    tokenLock.lockTokens(beneficiary, releaseTime, bonusTokens);
  }


}