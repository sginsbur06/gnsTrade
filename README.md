# [M-02] Missing Min Max validation for `sacMultiplier`

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1093

## Severity

**Impact:**
High, as this will lead to a monetary loss for users

**Likelihood:**
Low, as it requires a big error on owner's side

## Description

The method `setSacrificeContract` is implemented so that there are no any restrictions on the minimum and maximum values of the parameter `sacMultiplier`. This parameter is used in calculating the size of the user’s deposit in method `deposit` (in particular, `sacMultiplier == 0` will result in the complete loss of the user's funds).

## Recommendations

It is recommended to add storage variables defining Min and Max values of `sacMultiplier`.
Add a suitable check to the method `setSacrificeContract`.
