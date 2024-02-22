# [M-02] Missing checking on the setter method of a descending order of values

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L910C1-L925C4

## Severity

**Impact:**
High, as it will result in wrong points calculations

**Likelihood:**
Low, as it requires a big error on owner's side

## Description

The logic of the method `getBonusPercent` involves searching through `bonusTiers[i].amount` values, starting from largest to smallest (in order to find the first “greater than”). This imposes special requirements on the formation of the order of values within the array passed to the setter `setBonusTiers`. However, the method `setBonusTiers` does not check array values. This can lead to `amount` values in the `bonusTiers` array not being in descending order, which will lead to incorrect calculation of bonusPercent.

## Recommendations

Add a check in the method `setBonusTiers` that `amount` values in the `bonusTiers` input array are in descending order.
