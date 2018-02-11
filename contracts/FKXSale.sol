pragma solidity ^0.4.18;

import "./FKX.sol";
import "./FKXTokenTimeLock.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title FKXSale
 * @dev FKXSale smart contracat used to mint and distrubute FKX tokens and lock up FKX tokens in the FKXTokenTimeLock smart contract.
 * Inheritance:
 * Ownable - lets FKXSale be ownable
 *
 */
contract FKXSale is Ownable {

  FKX public token;

  FKXTokenTimeLock public tokenLock;

  function FKXSale() public {

    token =  new FKX();

    tokenLock = new FKXTokenTimeLock(token);

  }

  /**
  * @dev Finalizes the sale and  token minting
  */
  function finalize() public onlyOwner {
    // Disable minting of FKX
    token.finishMinting();
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
    require(!tokenLock.exists(beneficiary));
    
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
    require(!tokenLock.exists(beneficiary));

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

  /**
  * @dev Release locked tokens to all beneficiaries if they are due.
  * @param from the start lock index
  * @param to the end lock index
  */
  function releaseAll(uint from, uint to) public onlyOwner returns (bool) {
    tokenLock.releaseAll(from, to);

    return true;
  }


}