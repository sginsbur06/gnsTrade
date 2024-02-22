# [M-02] Missing checking that input array lengths are equal to each other

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L920
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatteryManager.sol#L59

## Severity

**Impact:**
Medium, as it will not lead to the loss of funds

**Likelihood:**
Low, as it requires a big error on owner's side

## Description

In contract `MarketplaceInteract`
  - `setBonusTiers` method does not check if input array lengths are equal to each other.

In contract `MicrogridBatteryManager`
  - `activateBattery` method does not check if input array lengths are equal to each other.

## Recommendations

Add a checks that input array lengths are equal to each other. 
