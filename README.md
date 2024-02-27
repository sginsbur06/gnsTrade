- ## Critical Risk Findings
    - [C-01. It's impossible for a user to claim his rewards, as `performUpkeep`, `claimFor`, `claimForMany` leaves rewards on contracts `BatteryInteractWETH` and `BatteryInteractWBNB`](#C-01)
    - [C-02. Wrong receiver's implementation in `claimFor` will result in loss of rewards](#C-02. Wrong receiver's implementation in `claimFor` will result in loss of rewards)
    - [C-03. User's rewards to be lost until the method `compoundFor` is called for the first time](#C-03)
    - [C-04. User can manipulate with adding and removing receivers, which will lead to incorrect calculation of rewards](#C-04)
    - [C-05. Calculation in `addPoints` reduces the user's balance](#C-05)






# Detailed Findings

# Critical Risk Findings

## <a id='C-01'></a>C-01. It's impossible for a user to claim his rewards, as `performUpkeep`, `claimFor`, `claimForMany` leaves rewards on contracts `BatteryInteractWETH` and `BatteryInteractWBNB`

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionAutoClaimUpkeep.sol#L44

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L251

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L275

## Severity

**Impact:**
High, because users will never receive rewards from the contract

**Likelihood:**
High, as this will happen any time the method is used

## Description

The `performUpkeep` method should send rewards for each user using `Battery` contract logic. However, this does not work, since in method `claimForMany` on contract `FusionRewardDistributor` the receivers are contracts `BatteryInteractWETH` and `BatteryInteractWBNB`. (The same situation occurs when calling methods `claimFor` or `claimForMany` directly). Since method `run` is not called further on contracts `BatteryInteractWETH` and `BatteryInteractWBNB`, all rewards remain on these contracts and will not distributed further.

This is wrong because it leads to loss of rewards.

## Recommendations

Revise method `performUpkeep` to include logic related to further distribution of rewards to users.
Restrict direct use of methods `claimFor`, `claimForMany`. 



## C-02. Wrong receiver's implementation in `claimFor` will result in loss of rewards 

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L251

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L95

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L123

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L428

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatteryManager.sol#L64

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatteryManager.sol#L12

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

Add the mapping for pairs `MicrogridBattery` - `BatteryInteract` and AddressSet `_listOfReceiversInteractContracts` in contract `FusionRewardDistributor`

```diff
+ mapping(address => address) public receiversInteractContracts;
+ EnumerableSet.AddressSet private _listOfReceiversInteractContracts;
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
+   if (!_listOfReceiversInteractContracts.contains(_receiverInteractContracts)) _listOfReceiversInteractContracts.add(_receiverInteractContracts);
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
```diff
  interface IFusionRewardDistributor {
-   function setReceivers(uint256 _microgridNftId, uint256[] calldata _allocPoints, address[] calldata _receivers) external;
+   function setReceivers(uint256 _microgridNftId, uint256[] calldata _allocPoints, address[] calldata _receivers, address[] calldata _receiverInteractContracts) external;
  }
```



## <a id='C-03'></a>C-03. User's rewards to be lost until the method `compoundFor` is called for the first time

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L216

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L243

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L212

## Severity

**Impact:**
High, as this will lead to a monetary loss for users

**Likelihood:**
High, as this will happen with each user

## Description

Each new user has `last_distPoints == 0`. When the method `compoundFor` (or `compoundForMany`, `compound`) is called for the first time, the `last_distPoints` is initialized (and in fact, only from this moment does the counting of rewards for a given user start). In according with this code:

```solidity
  function compoundFor(uint256 _id, bool _claimBefore) public whenNotPaused {
    if (last_distPoints[_id][address(this)] == 0) {
      last_distPoints[_id][address(this)] = totalDistributePoints;
    }
    if (_claimBefore) {
      _tryClaimFarm();
    }
    .........
```
This causes the user's rewards to be lost until the methods are called for the first time.

## Recommendations

It is necessary to revise the logic so that when a user is added into protocol, method `_tryClaimFarm` is executed and `last_distPoints` in `FusionRewardDistributor` is initialized
```solidity
  last_distPoints[_id][address(this)] = totalDistributePoints;
```



## <a id='C-04'></a>C-04. User can manipulate with adding and removing receivers, which will lead to incorrect calculation of rewards

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol#L95

## Severity

**Impact:**
High, as it will result in wrong reward calculations

**Likelihood:**
High, as it requires no preconditions

## Description

The method  `_setReceiver` should initialize the `last_distPoints` when adding a new receiver as it's implemented with this code:

```solidity
  if (last_distPoints[_microgridNftId][_receiver] == 0) {
    last_distPoints[_microgridNftId][_receiver] = totalDistributePoints;
  }
```
But the user can remove their previously initialized receiver and then add it again (in which case the initialization will not occur). This way the user will be able to receive extra rewards for this receiver.

## Recommendations

Need to initialize the receiver every time it is added.
Change the code in the following way:

```diff
- if (last_distPoints[_microgridNftId][_receiver] == 0) {
    last_distPoints[_microgridNftId][_receiver] = totalDistributePoints;
- }
```
