# [H-02] Disabled `microgridBatteryNFTContracts` are not removed from the array

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatteryManager.sol#L59
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatteryManager.sol#L64

## Severity

**Impact:**
Low, as it will not lead to the loss of funds or restrict the functionality of contract

**Likelihood:**
Low, as it happens only for the case of removing battery

## Description

The method `activateBattery` when disabling a previously added `microgridBatteryNFTContracts` (`allocPoints == 0`), does not remove it from the array `batteryInfo.ownedBatteries`. 
Therefore, the method `getBatteryListByUser` will always return a complete list of all user's `microgridBatteryNFTContracts` (with `allocPoints == 0` and `allocPoints > 0`).

## Recommendations

Add logic that removes inactive `microgridBatteryNFTContracts` from the array (using OpenZeppelin’s EnumerableSet is also possible).
