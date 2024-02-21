

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/FusionAutoClaimUpkeep.sol#L32
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L428

## Severity

**Impact:**
Medium, as this will lead to a incomplete use of protocol capabilities

**Likelihood:**
Medium, as it happens only for using of AutoClaim

## Description

Method `checkUpkeep` generates a list of receivers using an external call to method `listClaimableReceivers` on contract `FusionRewardDistributor`. Since this happens before receiving rewards on `FusionRewardDistributor` through `_tryClaimFarm`, the method `getTotalRewards` gives a result of 0, and the receiver will not be included in the `eligibleReceivers` list (according to the following code):

```solidity
if (getTotalRewards(_tokenId, _receiver) >= IBattery(_receiver).minClaimAmount()) {
  eligibleReceivers[eligibleCount++] = _receiver;
}
```
Therefore `checkUpkeep` will generate always an empty list and method `performUpkeep` a will not work.

## Recommendations

Remove check in the method `listClaimableReceivers`.
Change the code in the following way:

```diff
  function listClaimableReceivers(uint256 _startIndex, uint256 _endIndex) external view returns (uint256[] memory, address[][] memory) {
    // Ensure _endIndex is within the bounds of the active token IDs array
    _endIndex = Math.min(_endIndex + 1, activeTokenIds.length());

    // Initialize temporary arrays to hold token IDs and receivers
    uint256[] memory tokenIds = new uint256[](_endIndex - _startIndex);
    address[][] memory temp = new address[][](_endIndex - _startIndex);

    uint256 counter = 0; // A counter to keep track of how many eligible receivers we've found

    // Loop over the specified range of token IDs
    for (uint256 i = _startIndex; i < _endIndex; i++) {
      uint256 _tokenId = activeTokenIds.at(i);
      uint256 _numReceivers = activeReceivers[_tokenId].length();

      // Initialize an array to hold the eligible receivers for the current token ID
      address[] memory eligibleReceivers = new address[](_numReceivers);
      uint256 eligibleCount = 0;

      // Loop over all receivers for the current token ID
      for (uint256 j = 0; j < _numReceivers; j++) {
        address _receiver = activeReceivers[_tokenId].at(j);

-       // If the receiver can claim rewards, add them to the eligibleReceivers array
-       if (getTotalRewards(_tokenId, _receiver) >= IBattery(_receiver).minClaimAmount()) {
          eligibleReceivers[eligibleCount++] = _receiver;
-       }
      }

        ........................
``` 
