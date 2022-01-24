# Name Registration System

`Name` contract allows us to register and lock a name for 1 hour. For locking the contract charges 1000 wei per byte.

When the lock expires another user can register and lock the same name and the previous user gets refund looses his ownership.

A user can renew his lock any number of times without any extra fee.

It protects from front running attacks using commit-reveal scheme. Reference links for commit-reveal-scheme:

- https://docs.soliditylang.org/en/v0.5.3/solidity-by-example.html#blind-auction
- https://medium.com/swlh/exploring-commit-reveal-schemes-on-ethereum-c4ff5a777db8

## Run the following command to test it:

```shell
npx hardhat test
```
