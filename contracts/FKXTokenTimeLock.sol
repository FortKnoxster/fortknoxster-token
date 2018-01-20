pragma solidity ^0.4.18;

import "./FKX.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title FKXTokenTimeLock
 * @dev FKXTokenTimeLock is a token holder contract that will allow multiple
 * beneficiaries to extract the tokens after a given release time. It is a modification of the  
 * OpenZeppenlin TokenTimeLock to allow for one lock to many beneficiaries. 
 */
contract FKXTokenTimeLock is Ownable {

  /**
   * Encapsulates information abount a beneficiary's token time lock.
   */
  struct TokenTimeLockVault {
      /**
       * Amount of locked tokens.
       */
      uint256 amount;

      /**
       * Timestamp when token release is enabled
       */
      uint256 releaseTime;
  }

  // ERC20 basic token contract being held
  FKX public token;

  // beneficiary of tokens after they are released
  //address public beneficiary;
  mapping(address => TokenTimeLockVault) public tokenLocks;

  // timestamp when token release is enabled
  //uint64 public releaseTime;

  function FKXTokenTimeLock(FKX _token) public {
    token = _token;
  }

  function lockTokens(address _beneficiary, uint256 _releaseTime, uint256 _tokens) external onlyOwner  {
    require(_releaseTime > now);
    require(_tokens > 0);

    TokenTimeLockVault storage lock = tokenLocks[_beneficiary];
    lock.amount = _tokens;
    lock.releaseTime = _releaseTime;

    LockEvent(_beneficiary, _tokens, _releaseTime);

  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    TokenTimeLockVault memory lock = tokenLocks[msg.sender];

    require(now >= lock.releaseTime);

    require(lock.amount > 0);

    delete tokenLocks[msg.sender];

    UnlockEvent(msg.sender);

    //token.safeTransfer(msg.sender, lock.amount);
    assert(token.transfer(msg.sender, lock.amount));
    
    
  }

  /**
   * @notice Transfers tokens held by timelock to all beneficiaries.
   */
  /*function releaseAll() public onlyOwner {


  }*/

  /**
   * Logged when tokens were time locked.
   *
   * @param beneficiary beneficiary to receive tokens once they are unlocked
   * @param amount amount of locked tokens
   * @param releaseTime unlock time
   */
  event LockEvent(address indexed beneficiary, uint256 amount, uint256 releaseTime);

  /**
   * Logged when tokens were unlocked and sent to beneficiary.
   *
   * @param beneficiary beneficiary to receive tokens once they are unlocked
   */
  event UnlockEvent(address indexed beneficiary);


  
}
