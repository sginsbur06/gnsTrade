# [L-02] Missing validation for `bonusStartTime` and `bonusEndTime` of `BonusMultiplier`

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1062

## Severity

**Impact:**
Low, as it will not lead to the loss of funds or big restriction on the functionality of protocol

**Likelihood:**
Low, as it requires a big error on owner's side

## Description

The method `setBonusMultiplier` do not validate that `bonusStartTime` is less than `bonusEndTime`. If those values are not correctly set, then applying the parameter `bonusMultiplier` will become impossible.

## Recommendations

Add a validation logic inside `setBonusMultiplier` method to ensure that `bonusStartTime` is less than `bonusEndTime`.
