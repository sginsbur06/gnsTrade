# [C-04] Malicious user can manipulate by adding and removing receivers, leading to incorrect calculation of rewards

### Relevant GitHub Links
 
- [FusionRewardDistributor.sol](https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L95)

## Severity

**Impact:**
High, as it will result in incorrect reward calculations

**Likelihood:**
High, as it requires no preconditions

## Description

The method _setReceiver should initialize the last_distPoints when adding a new receiver as it's implemented with this code:
```Solidity

if (last_distPoints[_microgridNftId][_receiver] == 0) {
    last_distPoints[_microgridNftId][_receiver] = totalDistributePoints;
}
```

However, a malicious user can remove their previously initialized receiver and then add it again, causing the initialization not to occur.

A malicious user can initialize two receivers (MicrogridBatteryWBNB and MicrogridBatteryWETH), then remove one receiver. When distributing rewards, 100% will be sent to the second receiver. Subsequently, the user can remove the second receiver, connect the first one, and receive all rewards on the first receiver, allowing them to receive extra rewards.

## Recommendations

It is recommended to initialize the receiver every time it is added. Change the code as follows:

```diff

- if (last_distPoints[_microgridNftId][_receiver] == 0) {
    last_distPoints[_microgridNftId][_receiver] = totalDistributePoints;
- }
```
