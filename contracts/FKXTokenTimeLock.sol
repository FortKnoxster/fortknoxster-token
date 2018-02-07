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

  /*
   * Array with beneficiary lock indexes. 
   */
  address[] public lockIndexes;

  /**
   * Encapsulates information abount a beneficiary's token time lock.
   */
  struct TokenTimeLockVault {
      /**
       * Amount of locked tokens.
       */
      uint256 amount;

      /**
       * Timestamp when token release is enabled.
       */
      uint256 releaseTime;

      /**
       * Lock array index.
       */
      uint256 arrayIndex;
  }

  // ERC20 basic token contract being held.
  FKX public token;

  // All beneficiaries' token time locks.
  mapping(address => TokenTimeLockVault) public tokenLocks;

  function FKXTokenTimeLock(FKX _token) public {
    token = _token;
  }

  function lockTokens(address _beneficiary, uint256 _releaseTime, uint256 _tokens) external onlyOwner  {
    require(_releaseTime > now);
    require(_tokens > 0);

    TokenTimeLockVault storage lock = tokenLocks[_beneficiary];
    lock.amount = _tokens;
    lock.releaseTime = _releaseTime;
    lock.arrayIndex = lockIndexes.length;
    lockIndexes.push(_beneficiary);

    LockEvent(_beneficiary, _tokens, _releaseTime);
  }

  function exists(address _beneficiary) external onlyOwner view returns (bool) {
    TokenTimeLockVault memory lock = tokenLocks[_beneficiary];
    return lock.amount > 0;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    TokenTimeLockVault memory lock = tokenLocks[msg.sender];

    require(now >= lock.releaseTime);

    require(lock.amount > 0);

    delete tokenLocks[msg.sender];

    lockIndexes[lock.arrayIndex] = 0;

    UnlockEvent(msg.sender);

    assert(token.transfer(msg.sender, lock.amount));   
  }

  /**
   * @notice Transfers tokens held by timelock to all beneficiaries.
   * @param from the start lock index
   * @param to the end lock index
   */
  function releaseAll(uint from, uint to) external onlyOwner returns (bool) {
    require(from >= 0);
    require(to <= lockIndexes.length);
    for (uint i = from; i < to; i++) {
      address beneficiary = lockIndexes[i];
      if (beneficiary == 0) { //Skip any previously removed locks
        continue;
      }
      
      TokenTimeLockVault memory lock = tokenLocks[beneficiary];
      
      if (!(now >= lock.releaseTime && lock.amount > 0)) { // Skip any locks that are not due to be release
        continue;
      }

      delete tokenLocks[beneficiary];

      lockIndexes[lock.arrayIndex] = 0;
      
      UnlockEvent(beneficiary);

      assert(token.transfer(beneficiary, lock.amount));
    }
    return true;
  }

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
