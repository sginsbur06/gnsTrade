# [I-06] Unused `payable` state mutability

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WBNBBatteryInteract.sol#L1291
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1292
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol#L221

## Description

The method has a `payable` state mutability, but nowhere in the code implementation is `msg.value` used. (Also, the logic of the method does not imply the use of payment in BNB). This may cause the user's BNB to get stuck in contract.

  Functions with this issue:
  - `WBNBBatteryInteract.buyBattery`
  - `WETHBatteryInteract.buyBattery`
  - `BatteryInteractSplitMyPosition.buyBattery`


## Recommendations

Remove `payable` state mutability. 
