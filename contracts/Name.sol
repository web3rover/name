//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Name {
  /**
  * Pay 1000 wei per byte to lock
  */
  uint private constant feePerByte = 1000; 

  /**
  * User can lock for 1 hour
  */
  uint private constant lockSeconds = 3600;

  struct Lock {
    uint256 lockedAt;
    address lockedBy;
  }

  mapping (string => Lock) public locks;

  function requiredFees(string memory name) public pure returns (uint256) {
    return bytes(name).length * feePerByte;
  }

  function _refund(string memory name, address recepient) private {
    uint256 fees = requiredFees(name);
    (bool sent,) = recepient.call{value: fees}("");
    require(sent, "Failed to send Ether");
  }

  modifier _isSufficientFees (string memory name) {
    uint256 fees = requiredFees(name);
    require(msg.value >= fees, "Insufficient balance");
    _;
  }

  function register(string memory name) public payable _isSufficientFees(name) {
    Lock storage lock = locks[name];
    if(lock.lockedBy == address(0x00)) {
      locks[name] = Lock(block.timestamp, msg.sender);
    } else if (lock.lockedAt + lockSeconds < block.timestamp) {
      /**
      * Lock expired
      */
      _refund(name, lock.lockedBy);
      locks[name] = Lock(block.timestamp, msg.sender);
    } else {
      revert("Name is taken");
    }
  }

  function renew(string memory name) public {
    Lock storage lock = locks[name];
    if(lock.lockedBy == msg.sender) {
      lock.lockedAt = block.timestamp;
    } else {
      revert("Cannot renew");
    }
  }

  function expire(string memory name) public {
    Lock storage lock = locks[name];

    if (
      lock.lockedBy == msg.sender && 
      lock.lockedAt + lockSeconds < block.timestamp
    ) {
      _refund(name, lock.lockedBy);
      delete locks[name];
    } else {
      revert("Cannot expire name");
    }
  }
}
