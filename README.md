# [M-02] Use safeTransfer()/safeTransferFrom() instead of transfer()/transferFrom()

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L932

## Severity

**Impact:**
Medium, it affects user assets only with tokens that don’t correctly implement the latest EIP20 spec

**Likelihood:**
Medium, it affects only with tokens that don’t correctly implement the latest EIP20 spec

## Description

There is `transferFrom` calls that do not check the return value (some tokens signal failure by returning false).
It is a good idea to add a require() statement that checks the return value of ERC20 token transfers or to use something like OpenZeppelin’s safeTransfer()/safeTransferFrom() unless one is sure the given token reverts in case of a failure. Failure to do so will cause silent failures of transfers and affect token accounting in contract.

However, using require() to check transfer return values could lead to issues with non-compliant ERC20 tokens which do not return a boolean value. Therefore, it's highly advised to use OpenZeppelin’s safeTransfer()/safeTransferFrom().

## Proof of Concept

MarketplaceInteract.sol

[L945:](https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L945) `IERC20(token).transferFrom(msg.sender, address(marketplaceContract), amount);`

## Recommendations

Consider using safeTransfer()/safeTransferFrom() instead of transfer()/transferFrom().
