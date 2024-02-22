# [M-02] Missing checking on the setter method that the length of input array is equal to the required value

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L910C1-L925C4

## Severity

**Impact:**
High, as it will result in block the functionality of contract

**Likelihood:**
Low, as it requires a big error on owner's side

## Description

The `getBonusPercent` method loop over the `bonusTiers` array with condition `i < 10`. 

```solidity
  function getBonusPercent(uint256 amount) internal view returns (uint256) {
    for (uint256 i = 0; i < 10; i++) {
      if (amount >= bonusTiers[i].amount) {
        return bonusTiers[i].percent;
      }
    }

    return 0;
  }
```
However, in the method `setBonusTiers` the length of the `bonusTiers` array is not limited in any way. Thus, if the length of the `bonusTiers` array will be less than 10, then calling `getBonusPercent` will result in revert. This will block the functionality of the method `buyPoints.`

## Recommendations

Add a check that input array lengths in the method `setBonusTiers` are equal to 10. 
