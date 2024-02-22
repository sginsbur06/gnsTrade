# [C-02] Wrong receiver's implementation in `claimFor` will result in loss of rewards 

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L251
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L95
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L123
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L428
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatteryManager.sol#L64

## Severity

**Impact:**
High, as this will result in 0 rewards for users when they try to use methods `claimFor` or `claimForMany` 

**Likelihood:**
High, as this will happen any time the methods are used

## Description

The `claimFor` method sends user's rewards to the address of `_receiver` (the receivers are the `MicrogridBatteryWBNB` or `MicrogridBatteryWETH` contracts)

```solidity
eshare.safeTransfer(_receiver, rewards);
```
However, for further sending to users, rewards must be sent to the corresponding contracts `BatteryInteractWBNB` and `BatteryInteractWETH` (which have the appropriate logic for this). 
The issue is that in the current edition, all rewards remain on the `MicrogridBatteryWBNB` or `MicrogridBatteryWETH` contracts and will not distributed further.

## Recommendations

Add the mapping for pairs `MicrogridBattery` - `BatteryInteract` in contract `FusionRewardDistributor`

```diff
+ mapping(address => address) public receiversInteractContracts;
```

Change the code in the following way:

```diff
- function _setReceiver(uint256 _microgridNftId, uint256 _allocPoints, address _receiver) internal {
+ function _setReceiver(uint256 _microgridNftId, uint256 _allocPoints, address _receiver, address _receiverInteractContracts ) internal {
    require(verifiedReceivers[_receiver], "Caller is not verified receiver");

    totalReceiversAllocPoints[_microgridNftId] = totalReceiversAllocPoints[_microgridNftId].sub(receiversAllocPoints[_microgridNftId][_receiver]).add(
      _allocPoints
    );
    receiversAllocPoints[_microgridNftId][_receiver] = _allocPoints;
+   receiversInteractContracts[_receiver] = _receiverInteractContracts;
    if (last_distPoints[_microgridNftId][_receiver] == 0) {
      last_distPoints[_microgridNftId][_receiver] = totalDistributePoints;
    }

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
  }


- function setReceivers(uint256 _microgridNftId, uint256[] calldata _allocPoints, address[] calldata _receivers) public {
+ function setReceivers(uint256 _microgridNftId, uint256[] calldata _allocPoints, address[] calldata _receivers, address[] calldata _receiverInteractContracts) public {
    require(msg.sender == batteryManagerContract, "Caller must be the battery manager contract.");
    for (uint256 i = 0; i < _receivers.length; i++) {
-     _setReceiver(_microgridNftId, _allocPoints[i], _receivers[i]);
+     _setReceiver(_microgridNftId, _allocPoints[i], _receivers[i], _receiverInteractContracts[i]);
    }
  }
```

```diff
  function claimFor(uint256 _id, address _receiver, bool _saveGas) public whenNotPaused {
    if (receiversAllocPoints[_id][_receiver] > 0) {
      if (last_distPoints[_id][_receiver] == 0) {
        last_distPoints[_id][_receiver] = totalDistributePoints;
      }
      if (!_saveGas) {
        _tryClaimFarm();
      }

      uint256 rewards = _getDistributionRewards(_id, _receiver);

      if (rewards > 0) {
        esharePending = esharePending.sub(rewards);
        last_distPoints[_id][_receiver] = totalDistributePoints;

-       eshare.safeTransfer(_receiver, rewards);
+       eshare.safeTransfer(receiversInteractContracts[_receiver], rewards);

        if (!_saveGas) {
          emit Claim(_id, rewards);
        }
      }
    }
  }
```

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

        // If the receiver can claim rewards, add them to the eligibleReceivers array
-       if (getTotalRewards(_tokenId, _receiver) >= IBattery(_receiver).minClaimAmount()) {
+       if (getTotalRewards(_tokenId, _receiver) >= IBattery(receiversInteractContracts[_receiver]).minClaimAmount()) {
          eligibleReceivers[eligibleCount++] = _receiver;
        }
      }

        ........................
``` 

For contract `MicrogridBatteryManager` change the code in the following way:

```diff
- function activateBattery(uint256[] calldata _allocPoints, address[] calldata _microgridBatteryNFTContracts) public {
+ function activateBattery(uint256[] calldata _allocPoints, address[] calldata _microgridBatteryNFTContracts, address[] calldata _interactBatteryContracts) public {
    // Find user's Microgrid token ID and battery token ID.
    uint256 usersMicrogridToken = microgridContract.tokenByWallet(msg.sender);
    require(usersMicrogridToken > 0, "You must own a Microgrid NFT.");

    BatteryInfo storage batteryInfo = batteryInfoByTokenId[usersMicrogridToken];

-  fusionDistributorContract.setReceivers(usersMicrogridToken, _allocPoints, _microgridBatteryNFTContracts);
+  fusionDistributorContract.setReceivers(usersMicrogridToken, _allocPoints, _microgridBatteryNFTContracts, _interactBatteryContracts);

    for (uint256 i = 0; i < _microgridBatteryNFTContracts.length; i++) {
      bool ownsBattery = (IMicrogridBatteryNFT(_microgridBatteryNFTContracts[i])).checkBattery(usersMicrogridToken);

        for (uint256 i = 0; i < _microgridBatteryNFTContracts.length; i++) {
            bool ownsBattery = (IMicrogridBatteryNFT(_microgridBatteryNFTContracts[i])).checkBattery(usersMicrogridToken);
      require(ownsBattery == true, "Your Microgrid does not own this battery.");

      if (batteryInfo.ownsBatteries[_microgridBatteryNFTContracts[i]] == false) {
          batteryInfo.ownedBatteries.push(_microgridBatteryNFTContracts[i]);
          batteryInfo.ownsBatteries[_microgridBatteryNFTContracts[i]] == true;
      }
      batteryInfo.batteryPercents[_microgridBatteryNFTContracts[i]] = _allocPoints[i];

      emit ActivateBattery(usersMicrogridToken, _allocPoints[i] > 0);
    }
  }
```
