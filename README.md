
# [M-02] User may be incorrectly excluded from the list of `activeTokenIds`.

### Relevant GitHub Links
	
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L95

## Severity

**Impact:**
Medium, as it will not lead to the loss of rewards, but makes them unavailable through one method
**Likelihood:**
Medium, as it occurs only when calling automation

## Description

The method `_setReceiver` removes the user's `microgridNftId` from the list of `activeTokenIds` if `_allocPoints == 0` for `_receiver`.
As it's implemented with this code:

```solidity
  if (_allocPoints > 0) {
    if (!activeReceivers[_microgridNftId].contains(_receiver)) {
      activeReceivers[_microgridNftId].add(_receiver);
    }
    if (!activeTokenIds.contains(_microgridNftId)) {
      activeTokenIds.add(_microgridNftId);
    }
  } else {
    if (activeReceivers[_microgridNftId].contains(_receiver)) {
      activeReceivers[_microgridNftId].remove(_receiver);
    }
    if (activeTokenIds.contains(_microgridNftId)) {
      activeTokenIds.remove(_microgridNftId);
    }
  }
```
However, the user may still have other receivers with `_allocPoints > 0`. Excluding a user from the list of `activeTokenIds` will result in him being excluded from the distribution of rewards through a method `performUpkeep` in `FusionAutoClaimUpkeep`.

## Recommendations

Add additional check that the user has no active receivers left.
Change the code in the following way:

```diff
- if (activeTokenIds.contains(_microgridNftId)) {
+ if (activeTokenIds.contains(_microgridNftId) && activeReceivers[_microgridNftId].length() == 0) {
    activeTokenIds.remove(_microgridNftId);
  }
```
