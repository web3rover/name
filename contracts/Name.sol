//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

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

  struct Commit {
    uint256 feePaid;
    address commitedBy;
  }

  mapping (string => Lock) public locks;
  mapping (bytes32 => Commit) public commits;

  function feesRequired(string memory name) public pure returns (uint256) {
    return bytes(name).length * feePerByte;
  }

  function _refund(address recepient, uint256 amount) private {
    (bool sent,) = recepient.call{value: amount}("");
    require(sent, "Failed to send Ether");
  }

  function _isSufficientFees (string memory name, uint256 value) internal pure returns (bool) {
    uint256 fees = feesRequired(name);
    if (value >= fees) {
      return true;
    } else {
      return false;
    }
  }

  function commit(bytes32 _commitment) public payable {
    require(_commitment[0] != 0, "empty commitment");
    require(commits[_commitment].feePaid == 0, "commitment is already used");
    require(msg.value > 0, "you must send ether for name registration");

    commits[_commitment] = Commit(msg.value, msg.sender);
  }

  function reveal(string memory name, string memory blindingFactor) public {
    /**
    * To understand encodePacked see: https://www.youtube.com/watch?v=rxZR3ITZlzE
    */
    bytes32 _commitment = keccak256(abi.encodePacked(msg.sender, name, blindingFactor));
    uint256 feePaid = commits[_commitment].feePaid;

    require(feePaid > 0, "commit not found");
    delete commits[_commitment];

    if (!_isSufficientFees(name, feePaid)) {
      revert("insufficient fees");
    }

    Lock storage lock = locks[name];
    if(lock.lockedBy == address(0x00)) {
      locks[name] = Lock(block.timestamp, msg.sender);
      // refund extra fee paid
      _refund(msg.sender, feePaid - feesRequired(name));
    } else if (lock.lockedAt + lockSeconds < block.timestamp) {
      /**
      * Lock expired
      */
      _refund(lock.lockedBy, feesRequired(name));
      locks[name] = Lock(block.timestamp, msg.sender);
      _refund(msg.sender, feePaid - feesRequired(name));
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
      _refund(lock.lockedBy, feesRequired(name));
      delete locks[name];
    } else {
      revert("Cannot expire name");
    }
  }

  function commitment(address sender, string memory name, string memory blindingFactor) pure public returns (bytes32) {
    return keccak256(abi.encodePacked(sender, name, blindingFactor));
  }
}
