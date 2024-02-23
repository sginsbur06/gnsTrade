# [M-02] Wrong use of `transferFrom` ERC721A for transfer to `address(0)`

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPosition.sol#L232

## Severity

**Impact:**
Medium, as it will not lead to the loss of funds

**Likelihood:**
Medium, as it does not affect the functionality of the entire protocol

## Description

The `upgradeBattery` removes ownership of battery and then must `burn` `BatteryNFT`. The issues are that:
  - contract `MicrogridBatterySplitMyPosition` a inherits from contract `ERC721A`, in which `transferFrom` to the address(0) is prohibited
  - `usersMicrogridToken Id` is passed as a parameter for burn, but the `MicrogridBatterySplitMyPosition Id` should be passed (in addition, it's necessary to take into account that all `MicrogridBatterySplitMyPosition NFT` belong to the `address(this)`)
  - in the current implementation the method does not work

## Recommendations

It is recommended to use the method `_burn` with the correct `NFT Id` as parameter. 
