pragma solidity ^0.4.11;

import "./FKX.sol";
import "./TokenCappedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol";
import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title FKXCrowdsale
 * @dev The FKX crowdsale based
 * Inheritance:
 * TokenCappedCrowdsale - sets a max boundary in FKX token for raised funds (from zeppelin-solidity's CappedCrowdsale.sol)
 * FinalizableCrowdsale - makes the crowdsale finalizable
 *
 */
contract FKXCrowdsale is TokenCappedCrowdsale, FinalizableCrowdsale {

  using SafeMath for uint256;

  uint256 public constant DECIMALS      = 18;
  //uint256 public constant TOTAL_SUPPLY  = 135000000 * (10 ** DECIMALS); // 135 Million FKX
  uint256 public constant TOKEN_CAP     = 80325000  * (10 ** DECIMALS); // 80.325 Million FKX
  uint256 public constant PRE_TOKEN_CAP = 9450000   * (10 ** DECIMALS); // 9.45 Million FKX

  // Whitelisted wallet to receive 20% bonus from presale.
  address public presaleWallet;

  uint256 public preRate;

  uint256 public fixedRate;

  uint256 public totalPreSaleTokens;

  function FKXCrowdsale(
      uint256 _startTime, 
      uint256 _endTime, 
      uint256 _rate,
      uint256 _preRate, 
      address _multiSigWallet,
      address _presaleWallet,
      address _communityWallet,
      address _partnersWallet,
      address _companyWallet,
      address _foundersWallet
    ) public
    
    TokenCappedCrowdsale(TOKEN_CAP)
    FinalizableCrowdsale()
    Crowdsale(_startTime, _endTime, _rate, _multiSigWallet) {

    require(_presaleWallet    != 0x0);
    require(_communityWallet  != 0x0);
    require(_partnersWallet   != 0x0);
    require(_companyWallet    != 0x0);
    require(_foundersWallet   != 0x0);

    setPreRate(_preRate);
    setRate(_rate);

    presaleWallet =  _presaleWallet;

    // Allocate tokens to the Advisors & Partners (12% - 16200000 FKX)
    mintTokens(_partnersWallet,   16200000 * (10 ** DECIMALS));

    // Allocate tokens to the Community (11% - 14850000 FKX)
    mintTokens(_communityWallet,  14850000 * (10 ** DECIMALS));   

    // Allocate tokens to the Company (10% - 13500000 FKX)
    mintTokens(_companyWallet,    13500000 * (10 ** DECIMALS));

    // Allocate tokens to the Founders (7.5% - 10125000 FKX)
    mintTokens(_foundersWallet,   10125000 * (10 ** DECIMALS));
  }

  function createTokenContract() internal returns (MintableToken) {
    FKX token = new FKX();
    token.pause();
    return token;
  }

  /**
  * @dev Finalizes the crowdsale
  */
  function finalization() internal {
      super.finalization();

      // Burn any remaining tokens
      if (token.totalSupply() < tokenCap) {
          uint tokens = tokenCap.sub(token.totalSupply());
          FKX(token).burn(tokens);
      }

      // disable minting of FKX tokens
      token.finishMinting();
  }

  /**
    * @dev Pause the FKX token.
    */
    function pauseTokens() public onlyOwner {
        FKX(token).pause();
    }

    /**
    * @dev Unpause the FKX token.
    */
    function unpauseTokens() public onlyOwner {
        FKX(token).unpause();
    }

  /**
   * @dev This function will be called 4-6 hours before the crowdsale begins.
   * Updates the ETH/FKX rate, before the crowdsale starts.
   * 
   */
  function setRate(uint256 _rate) public onlyOwner {
    require(_rate > 0x0);
    require(now <= startTime); // Cannot be called during the crowdsale period  
    rate =  _rate;
    fixedRate = rate;
    RateChange(_rate);
  }

  /**
   * @dev This function will be called 4-6 hours before the crowdsale begins.
   * Updates the ETH/FKX rate for presale, before the crowdsale starts.
   * 
   */
  function setPreRate(uint256 _preRate) public onlyOwner {
    require(_preRate > 0x0);
    require(now <= startTime); // Cannot be called during the crowdsale period  
    preRate =  _preRate;
    PreRateChange(_preRate);
  }

  event RateChange(uint256 rate);
  event PreRateChange(uint256 preRate);
  event LogMsg(string msg);

  /**
   * @dev Overrided buyTokens method of parent Crowdsale contract  to provide bonus by changing and restoring rate variable
   * @param beneficiary wallet of investor to receive tokens
   */
  function buyTokens(address beneficiary) public payable {
    // Apply bonus by adjusting and restoring rate member
    uint256 oldRate = rate;
    if (beneficiary ==  presaleWallet) {
      rate = preRate;      
      uint256 weiAmount = msg.value;
      // calculate token amount to be created
      uint256 tokens = totalPreSaleTokens.add(weiAmount.mul(rate));

      require(tokens <= PRE_TOKEN_CAP);
      
      super.buyTokens(beneficiary);      
      // Update pre-sale tokens
      totalPreSaleTokens =  tokens;
    }
    else {
      rate = fixedRate;
      super.buyTokens(beneficiary);
    }
    rate = oldRate;
  }

  // 
  /**
  * @dev Allocates tokens for whitelisted wallets.
  * @param beneficiary whitelisted wallet to receive tokens
  * @param tokens amount of tokens to be received by beneficiary
  */
  function mintTokens(address beneficiary, uint256 tokens) public onlyOwner {
    LogMsg("mintTokens Before");
    require(beneficiary != 0x0);
    require(tokens > 0);
    require(now <= endTime);                               // Crowdsale (without startTime check)
    require(!isFinalized);                                 // FinalizableCrowdsale
    require(token.totalSupply().add(tokens) <= tokenCap); // TokensCappedCrowdsale
    
    token.mint(beneficiary, tokens);
    LogMsg("mintTokens After");
  }


}