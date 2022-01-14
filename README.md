# Name Registration System

`Name` contract allows us to register and lock a name for 1 hour. For locking the contract charges 1000 wei per byte.

When the lock expires another user can register and lock the same name and the previous user gets refund looses his ownership.

A user can renew his lock any number of times without any extra fee.

Run the following command to test it:

```shell
npx hardhat test
```