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

  FKX public token;

  FKXTokenTimeLock public tokenLock;

  function FKXSale(FKX _fkxToken) public {

    token =  _fkxToken;

    tokenLock = new FKXTokenTimeLock(token);

  }

  /**
  * @dev Finalizes the sale and  token minting
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

  /**
  * @dev Allocates tokens and bonus tokens to early-bird contributors.
  * @param beneficiary wallet
  * @param baseTokens amount of tokens to be received by beneficiary
  * @param bonusTokens amount of tokens to be locked up to beneficiary
  * @param releaseTime when to unlock bonus tokens
  */
  function mintBaseLockedTokens(address beneficiary, uint256 baseTokens, uint256 bonusTokens, uint256 releaseTime) public onlyOwner {
    require(beneficiary != 0x0);
    require(baseTokens > 0);
    require(bonusTokens > 0);
    require(releaseTime > now);
    
    // Mint base tokens to beneficiary
    token.mint(beneficiary, baseTokens);

    // Mint beneficiary's bonus tokens to the token time lock
    token.mint(tokenLock, bonusTokens);

    // Time lock the tokens
    tokenLock.lockTokens(beneficiary, releaseTime, bonusTokens);
  }

  /**
  * @dev Allocates bonus tokens to advisors, founders and company.
  * @param beneficiary wallet
  * @param tokens amount of tokens to be locked up to beneficiary
  * @param releaseTime when to unlock bonus tokens
  */
  function mintLockedTokens(address beneficiary, uint256 tokens, uint256 releaseTime) public onlyOwner {
    require(beneficiary != 0x0);
    require(tokens > 0);
    require(releaseTime > now);

    // Mint beneficiary's bonus tokens to the token time lock
    token.mint(tokenLock, tokens);

    // Time lock the tokens
    tokenLock.lockTokens(beneficiary, releaseTime, tokens);
  }

  /**
  * @dev Allocates tokens to beneficiary.
  * @param beneficiary wallet
  * @param tokens amount of tokens to be received by beneficiary
  */
  function mintTokens(address beneficiary, uint256 tokens) public onlyOwner {
    require(beneficiary != 0x0);
    require(tokens > 0);
    
    // Mint tokens to beneficiary
    token.mint(beneficiary, tokens);
  }


}