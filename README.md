
# [M-02] Missing missing a method for setting BNB `pointsPerDollar`

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol

## Severity

**Impact:**
High, as this will lead to a monetary loss for users and restrict the functionality of contract

**Likelihood:**
Medium, it affects user assets only with paying with BNB

## Description

The `MarketplaceInteract` is missing a method for setting BNB `pointsPerDollar`. This can lead to the loss of user funds when calling the method `buyPoints` and paying with BNB.

## Recommendations

Add a setter for BNB `pointsPerDollar`.
