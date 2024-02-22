# [I-06] Unused method `burn`

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPosition.sol#L225
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol

## Description

The method `burn` can only be externally called by the contract `MicrogridBatterySplitMyPositionInteract`.
```solidity
  require(interactContract == msg.sender, "Only the interact contract can burn.");
```
However, `MicrogridBatterySplitMyPositionInteract` implementation does not have the functionality to call method `burn` in `MicrogridBatterySplitMyPosition`.

## Recommendations

Add the necessary functionality to the contract `MicrogridBatterySplitMyPositionInteract` or remove unused method `burn`.
