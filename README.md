- ## Critical Risk Findings
    - [C-01. It's impossible for a user to claim his rewards, as `performUpkeep`, `claimFor`, `claimForMany` leaves rewards on contracts `BatteryInteractWETH` and `BatteryInteractWBNB`](#c-01-its-impossible-for-a-user-to-claim-his-rewards-as-performupkeep-claimfor-claimformany-leaves-rewards-on-contracts-batteryinteractweth-and-batteryinteractwbnb)
    - [C-02. Wrong receiver's implementation in `claimFor` will result in loss of rewards](#c-02-wrong-receivers-implementation-in-claimfor-will-result-in-loss-of-rewards)
    - [C-03. User's rewards to be lost until the method `compoundFor` is called for the first time](#c-03-users-rewards-to-be-lost-until-the-method-compoundfor-is-called-for-the-first-time)
    - [C-04. User can manipulate with adding and removing receivers, which will lead to incorrect calculation of rewards](#c-04-user-can-manipulate-with-adding-and-removing-receivers-which-will-lead-to-incorrect-calculation-of-rewards)
    - [C-05. Calculation in `addPoints` reduces the user's balance](#c-05-calculation-in-addpoints-reduces-the-users-balance)
    - [C-06. Calculation for `finalAmount` will result in wrong decimals](#c-06-calculation-for-finalamount-will-result-in-wrong-decimals)
    - [C-07. Wrong calculation for `finalAmount` may lead to loss of user funds](#c-07-wrong-calculation-for-finalamount-may-lead-to-loss-of-user-funds)
    - [C-08. Logic of `deposit` under conditions of `Sacrifice` is not implemented](#c-08-logic-of-deposit-under-conditions-of-sacrifice-is-not-implemented)
    - [C-09. Wrong calculation for `amountWithBonus` may lead to loss of user funds](#c-09-wrong-calculation-for-amountwithbonus-may-lead-to-loss-of-user-funds)
    - [C-10. Mint to an incorrectly specified address makes it impossible to buy a Battery NFT](#c-10-mint-to-an-incorrectly-specified-address-makes-it-impossible-to-buy-a-battery-nft)
    - [C-11. Accounting and updating `last_distPoints` allow malicious users to receive additional rewards](#c-11-accounting-and-updating-last_distpoints-allow-malicious-users-to-receive-additional-rewards)
    - [C-12. Calculation for `ExchangeRate` will result in wrong decimals](#c-12-calculation-for-exchangerate-will-result-in-wrong-decimals)
    - [C-13. It's impossible for a user to claim his rewards, as `run` and `runFromUpkeep` will not pass `currentMinClaim` check](#c-13-its-impossible-for-a-user-to-claim-his-rewards-as-run-and-runfromupkeep-will-not-pass-currentminclaim-check)
    - [C-14. Wrong calculation in `buyOrder` increases the `refundAmount`](#c-14-wrong-calculation-in-buyorder-increases-the-refundamount)
    - [C-15. Missing a method for setting `MarketplaceContract`](#c-15-missing-a-method-for-setting-marketplacecontract)




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



## <a id='C-02'></a>C-02. Wrong receiver's implementation in `claimFor` will result in loss of rewards 

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



## <a id='C-04'></a>C-04. Malicious user can manipulate with adding and removing receivers, which will lead to incorrect calculation of rewards

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



## <a id='C-05'></a>C-05. Calculation in `addPoints` reduces the user's balance

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceExchange.sol#L100

## Severity

**Impact:**
High, as this will lead to a monetary loss for users

**Likelihood:**
High, as this will happen any time the user buys points

## Description

The method `addPoints` calculates incorrectly. When adding a `purchaseAmount` it reduces the user's balance.

## Recommendations

Change the code in the following way:

```diff
  function addPoints(uint256 microgridId, uint256 purchaseAmount) external {
    require(allowedCreditors[msg.sender] == true, "Only allowed creditors can add points.");
-   userBalance[microgridId] -= purchaseAmount;
+   userBalance[microgridId] += purchaseAmount;
  }
```



## <a id='C-06'></a>C-06. Calculation for `finalAmount` will result in wrong decimals

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L932

## Severity

**Impact:**
High, as it will result in wrong points calculations

**Likelihood:**
High, as this will happen any time the user buys points

## Description

The method `buyPoints` is implemented so that 
  - during calculations `finalAmount` is obtained with a decimals 1e18 times large than necessary (in cases `token == address(empToken)` or `allowedCurrencies[token].exRateHelper == true`)
  - during calculations `finalAmount` is obtained with a decimals 1e18 times less than necessary (in other cases)

## Recommendations

Change the code in the following way:

```diff
    // If token is being spent to purchase Marketplace Points.
    if (token != address(0)) {
      IERC20(token).transferFrom(msg.sender, address(marketplaceContract), amount);
      if (token == address(empToken)) {
-       uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token) * 1e18;
+       uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token);
        uint256 purchaseAmount = ((((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar) * 10000) * (calcRateEMP() / 1e18) / 10000;
        uint256 bonusPercent = getBonusPercent(purchaseAmount);
        uint256 finalAmount = ((((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar) * 10000) * (calcRateEMP() / 1e18) / 10000 * (bonusPercent * 10000) / 10000;
        marketplaceContract.addPoints(usersMicrogridId, finalAmount);
        emit PointsBought(usersMicrogridId, finalAmount);
      } else if (allowedCurrencies[token].exRateHelper == true) {
-       uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token) * 1e18;
+       uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token);
        uint256 purchaseAmount = ((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar;
        uint256 bonusPercent = getBonusPercent(purchaseAmount);
        uint256 finalAmount = ((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar * (bonusPercent * 10000) / 10000;
        marketplaceContract.addPoints(usersMicrogridId, finalAmount);
        emit PointsBought(usersMicrogridId, finalAmount);
      } else {
        int256 currentPrice = IAggregator(allowedCurrencies[token].priceAggregator).latestAnswer();
-       uint256 purchaseAmount = (((amount * (uint256(currentPrice) / 10 ** IAggregator(allowedCurrencies[token].priceAggregator).decimals())) / 1e18) * allowedCurrencies[token].pointsPerDollar);
+       uint256 purchaseAmount = ((amount * uint256(currentPrice) / 10 ** IAggregator(allowedCurrencies[token].priceAggregator).decimals()) * allowedCurrencies[token].pointsPerDollar);
        uint256 bonusPercent = getBonusPercent(purchaseAmount);
        uint256 finalAmount = (((amount * (uint256(currentPrice) / 10 ** IAggregator(allowedCurrencies[token].priceAggregator).decimals())) / 1e18) * allowedCurrencies[token].pointsPerDollar) * (bonusPercent *   10000) / 10000;
        marketplaceContract.addPoints(usersMicrogridId, finalAmount);
        emit PointsBought(usersMicrogridId, finalAmount);
      }

    // Else BNB is being spent.
    } else {
      payable(address(marketplaceContract)).transfer(msg.value);
      int256 currentPrice = IAggregator(aggregatorContract).latestAnswer();
-     uint256 purchaseAmount = (((msg.value * (uint256(currentPrice) / 10 ** IAggregator(aggregatorContract).decimals())) / 1e18) * pointsPerDollar);
+     uint256 purchaseAmount = ((msg.value * uint256(currentPrice) / 10 ** IAggregator(aggregatorContract).decimals()) * pointsPerDollar);
      uint256 bonusPercent = getBonusPercent(purchaseAmount);
      uint256 finalAmount = (((msg.value * (uint256(currentPrice) / 10 ** IAggregator(aggregatorContract).decimals())) / 1e18) * pointsPerDollar) * (bonusPercent * 10000) / 10000;
      marketplaceContract.addPoints(usersMicrogridId, finalAmount);
      emit PointsBought(usersMicrogridId, finalAmount);
    }
    
```  



## <a id='C-07'></a>C-07. Wrong calculation for `finalAmount` may lead to loss of user funds

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L932

## Severity

**Impact:**
High, as it will result in wrong points calculations and loss of user funds

**Likelihood:**
High, as this will happen any time the user buys points

## Description

The method `buyPoints` uses `bonusPercent`. But calculations are implemented incorrectly, which can lead to loss of user funds (for example, `with bonusPercent == 0`).

## Recommendations

Change the code in the following way:

```diff
    // If token is being spent to purchase Marketplace Points.
   if (token != address(0)) {
    IERC20(token).transferFrom(msg.sender, address(marketplaceContract), amount);
    if (token == address(empToken)) {
      uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token) * 1e18;
      uint256 purchaseAmount = ((((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar) * 10000) * (calcRateEMP() / 1e18) / 10000;
      uint256 bonusPercent = getBonusPercent(purchaseAmount);
-     uint256 finalAmount = ((((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar) * 10000) * (calcRateEMP() / 1e18) / 10000 * (bonusPercent * 10000) / 10000;
+     uint256 finalAmount = ((((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar) * 10000) * (calcRateEMP() / 1e18) / 10000 * (bonusPercent + 10000) / 10000;
      marketplaceContract.addPoints(usersMicrogridId, finalAmount);
      emit PointsBought(usersMicrogridId, finalAmount);
    } else if (allowedCurrencies[token].exRateHelper == true) {
      uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token) * 1e18;
      uint256 purchaseAmount = ((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar;
      uint256 bonusPercent = getBonusPercent(purchaseAmount);
-     uint256 finalAmount = ((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar * (bonusPercent * 10000) / 10000;
+     uint256 finalAmount = ((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar * (bonusPercent + 10000) / 10000;
      marketplaceContract.addPoints(usersMicrogridId, finalAmount);
      emit PointsBought(usersMicrogridId, finalAmount);
    } else {
      int256 currentPrice = IAggregator(allowedCurrencies[token].priceAggregator).latestAnswer();
      uint256 purchaseAmount = (((amount * (uint256(currentPrice) / 10 ** IAggregator(allowedCurrencies[token].priceAggregator).decimals())) / 1e18) * allowedCurrencies[token].pointsPerDollar);
      uint256 bonusPercent = getBonusPercent(purchaseAmount);
-     uint256 finalAmount = (((amount * (uint256(currentPrice) / 10 ** IAggregator(allowedCurrencies[token].priceAggregator).decimals())) / 1e18) * allowedCurrencies[token].pointsPerDollar) * (bonusPercent *   10000) / 10000;
+     uint256 finalAmount = ((amount * uint256(currentPrice) / 10 ** IAggregator(allowedCurrencies[token].priceAggregator).decimals()) * allowedCurrencies[token].pointsPerDollar) * (bonusPercent + 10000) / 10000;
      marketplaceContract.addPoints(usersMicrogridId, finalAmount);
      emit PointsBought(usersMicrogridId, finalAmount);
    }

    // Else BNB is being spent.
    } else {
      payable(address(marketplaceContract)).transfer(msg.value);
      int256 currentPrice = IAggregator(aggregatorContract).latestAnswer();
      uint256 purchaseAmount = (((msg.value * (uint256(currentPrice) / 10 ** IAggregator(aggregatorContract).decimals())) / 1e18) * pointsPerDollar);
      uint256 bonusPercent = getBonusPercent(purchaseAmount);
-     uint256 finalAmount = (((msg.value * (uint256(currentPrice) / 10 ** IAggregator(aggregatorContract).decimals())) / 1e18) * pointsPerDollar) * (bonusPercent * 10000) / 10000;
+     uint256 finalAmount = ((msg.value * uint256(currentPrice) / 10 ** IAggregator(aggregatorContract).decimals()) * pointsPerDollar) * (bonusPercent + 10000) / 10000;
      marketplaceContract.addPoints(usersMicrogridId, finalAmount);
      emit PointsBought(usersMicrogridId, finalAmount);
    }
    
```  



## <a id='C-08'></a>C-08. Logic of `deposit` under conditions of `Sacrifice` is not implemented

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1255

## Severity

**Impact:**
High, as this will lead to restriction on the functionality of protocol

**Likelihood:**
High, as this will happen any time the user try to deposit with sacrifice

## Description

The logic of the protocol assumes that in method `deposit` in cases `DepositType(depositType) == DepositType.BY_SACRIFICE` and `DepositType(depositType) == DepositType.BY_SACRIFICE_USD` a deposit will be carried out without the actual transfer of tokens (or BNB) from users to the contract `MicrogridNFT`.
The current version of the code does not implement this, and the transaction will revert.

## Recommendations

Change the code in the following way:

```diff

    if ((DepositType(depositType) == DepositType.BY_EMP_ETH_LP)) {
      empEthLpToken.transferFrom(tx.origin, address(microgridNFTContract), amount);

    } else if ((DepositType(depositType) == DepositType.DEFAULT)) {
      empToken.transferFrom(msg.sender, address(microgridNFTContract), amount);

    } else if ((DepositType(depositType) == DepositType.BY_UPEMP)) {
      upEmp.transferFrom(tx.origin, address(microgridNFTContract), amount);

    } else if ((DepositType(depositType) == DepositType.CURRENCY ||
      DepositType(depositType) == DepositType.CURRENCY_BY_TOKEN_ID) &&
      currency != address(0)) {
      (IERC20(currency)).transferFrom(msg.sender, address(microgridNFTContract), amount);

+   } else if ((DepositType(depositType) == DepositType.BY_SACRIFICE ||
+     DepositType(depositType) == DepositType.BY_SACRIFICE_USD)) {

    } else if (msg.value == 0){
      empToken.transferFrom(msg.sender, address(microgridNFTContract), amount);

    } else {
      payable(address(microgridNFTContract)).transfer(msg.value);
    }
    ...........
```



## <a id='C-09'></a>C-09. Wrong calculation for `amountWithBonus` may lead to loss of user funds

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1255

## Severity

**Impact:**
High, as it will result in wrong deposit calculations and loss of user funds

**Likelihood:**
High, as this will happen any time the user deposit

## Description

The method `deposit` in case of `DepositType(depositType) == DepositType.BY_SACRIFICE_USD` uses `currentPrice` of `empToken`. But calculations are implemented incorrectly.

Also, in cases `DepositType(depositType) == DepositType.CURRENCY` or `DepositType(depositType) == DepositType.CURRENCY_BY_TOKEN_ID`, there may be a situation that 
`getExchangeRate(address(empToken)) > getExchangeRate(address(currency))`. As a result of calculations, `currentPrice == 0`.

This can lead to loss of user funds.

## Recommendations

Change the code in the following way:

```diff
    if (DepositType(depositType) == DepositType.DEFAULT ||
      DepositType(depositType) == DepositType.BY_TOKEN_ID ||
      DepositType(depositType) == DepositType.FOR_NEW_USER) {
      amountWithBonus = (amountWithBonus * 10000) * (calcRateEMP() / 1e18) / 10000;

    } else if (DepositType(depositType) == DepositType.BY_SACRIFICE) {
      amountWithBonus = (amountWithBonus * allowedSacrifices[msg.sender].sacMultiplier) / 10000;

    } else if (DepositType(depositType) == DepositType.BY_SACRIFICE_USD) {
      uint256 currentPrice = (getExchangeRate(address(empToken)));
-     amountWithBonus = (((amountWithBonus * currentPrice) / 1e18) * allowedSacrifices[msg.sender].sacMultiplier) / 10000;
+     amountWithBonus = (((amountWithBonus / currentPrice) / 1e18) * allowedSacrifices[msg.sender].sacMultiplier) / 10000; 

    } else if ((DepositType(depositType) == DepositType.BY_UPEMP)) {
      amountWithBonus = (upEmp.calculatePrice() / 1e18) * amountWithBonus;

    } else if ((DepositType(depositType) == DepositType.BY_EMP_ETH_LP)) {
      amountWithBonus = ((amountWithBonus * 2 * 1e18 * empToken.balanceOf(address(empEthLpToken)) / empEthLpToken.totalSupply() / 1e18) * 10000) * (calcRateEMP() / 1e18) / 10000;
            
    } else if (DepositType(depositType) == DepositType.CURRENCY ||
      DepositType(depositType) == DepositType.CURRENCY_BY_TOKEN_ID) {
      int256 currentPrice = 0;
      uint256 _sharesPerEMP = sharesPerEMP;

      if (currency == address(0)) {
-      currentPrice = (int256(getExchangeRate(currency))) / (int256(getExchangeRate(address(empToken))));
+      currentPrice = (int256(getExchangeRate(currency) * 1e18)) / (int256(getExchangeRate(address(empToken))));
      } else {
-      currentPrice = (int256(getExchangeRate(currency))) / (int256(getExchangeRate(address(empToken))));
+      currentPrice = (int256(getExchangeRate(currency) * 1e18)) / (int256(getExchangeRate(address(empToken))));
        _sharesPerEMP = allowedCurrencies[currency].sharesPerEMP;
      }

      amountWithBonus= (amountWithBonus * ((uint256(currentPrice)) * _sharesPerEMP) / 1e18) / 1e18;
    }   
```   



## <a id='C-10'></a>C-10. Mint to an incorrectly specified address makes it impossible to buy a Battery NFT

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WBNBBatteryInteract.sol#L1291

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1292

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol#L221

## Severity

**Impact:**
High, as this will lead to a monetary loss for users

**Likelihood:**
High, as this will happen any time the user call method

## Description

The method `buyBattery` performs `mint` of `Battery NFT` via external call `batteryContract.mint` and the `address(batteryContract)` is passed as a parameter.

On the `Battery` contract `mint` is implemented by the following code:
```solidity
  function mint(address user, uint256 amount) external {
    uint256 usersMicrogridToken = microgridContract.tokenByWallet(user);
    require(interactContract == msg.sender, "Only the interact contract can mint.");
    require(ownsBattery[usersMicrogridToken] == false, "You already own this battery.");
    ownsBattery[usersMicrogridToken] = true;
    _mint(address(this), amount);
  }
```
Therefore, `msg.sender` must be passed as a parameter. The current implementation results in the loss of user funds, since the `NFT` is not issued to his address.

Functions with this issue:
  - `WBNBBatteryInteract.buyBattery`
  - `WETHBatteryInteract.buyBattery`
  - `BatteryInteractSplitMyPosition.buyBattery`

## Recommendations

Change the code in the following way:

```diff 
    // Purchase battery w/Marketplace Points.        
      marketplaceContract.spendPoints(usersMicrogridToken, batteryCost);

    // Mint NFT.
-     batteryContract.mint(address(batteryContract), 1);
+     batteryContract.mint(msg.sender, 1);

     ..........
``` 



## <a id='C-11'></a>C-11. Accounting and updating `last_distPoints` allow malicious users to receive additional rewards

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFT.sol

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol

## Severity

**Impact:**
High, as this will lead to a monetary loss for users

**Likelihood:**
High, since multiple attack vectors are possible

## Description

The `DistributePoints` value for each `user's receiver` is saved to mapping `last_distPoints`. These values are updated on the contract `FusionRewardDistributor`
```solidity
      last_distPoints[_id][_receiver] = totalDistributePoints;
```
This happens at:
  - adding a new `Battery receiver` (`_setReceiver`)
  - calling the method `compoundFor`
```solidity
  function compoundFor(uint256 _id, bool _claimBefore) public whenNotPaused {
    if (last_distPoints[_id][address(this)] == 0) {
      last_distPoints[_id][address(this)] = totalDistributePoints;
    }
    if (_claimBefore) {
      _tryClaimFarm();
    }

    if (totalReceiversAllocPoints[_id] == 0) {
      uint256 distributed = _getDistributionRewards(_id, address(this));

      if (distributed > 0) {
        last_distPoints[_id][address(this)] = totalDistributePoints;
        esharePending = esharePending.sub(distributed);
        eshareCompounded = eshareCompounded.add(distributed);

        nft.compoundForTokenId(distributed, _id);

        _tryClaimFarm();

        if (last_distPoints[_id][address(this)] != totalDistributePoints) last_distPoints[_id][address(this)] = totalDistributePoints;

        emit Compound(_id, distributed);
      }
    }
  }
```
Moreover, the update occurs only in the case of `totalReceiversAllocPoints == 0` (if user does not have a `Battery receiver`)
  - calling the method `claimFor`
```solidity
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

        eshare.safeTransfer(_receiver, rewards);

        if (!_saveGas) {
        emit Claim(_id, rewards);
        }
      }
    }
  }
```
This creates the following attack vectors:

**1. Via Deposit**

    The malicious user has

      MicrogridNFT id = 1

      individualShares = 100

      MicrogridBatteryWBNB - receiver

      receiversAllocPoints for user’s MicrogridBatteryWBNB = 1000

      totalReceiversAllocPoints for user’s = 1000

      last_distPoints[1][address(MicrogridBatteryWBNB)] = 50000

At the same time, on the contract `totalDistributePoints = 50000`.

The malicious user adds another `200 shares` via `deposit` on the `MicrogridNFTDeposit` contract (`addSharesByDeposit` on `MicrogridNFT`)
```solidity
  function addSharesByDeposit(uint256 amount, uint256 tokenId) external onlyDepositContract {
    require(_exists(tokenId), "Token does not exist");

    individualShares[tokenId] += amount;
    totalShares += amount;
    _updateRewardsAndPoints(tokenId);
  }
```
After adding, the method `updateRewardsAndPonts` is called on `FusionRewardDistributor`
```solidity
  function updateRewardsAndPoints(uint256 _id) external {
    require(_msgSender() == address(nft), "Caller is not MicroGridNFT");
    _tryClaimFarm();
    compoundFor(_id, false);
  }
```
This is where `rewards` are received from `Farm` (`_tryClaimFarm`) and `compoundFor` is called.

New value on the contract is `totalDistributePoints = 80000`.

However, the `compound` for malicious user does not occur (since `totalReceiversAllocPoints != 0`) and there is no update to the `last_distPoints` value either.

    New values

      individualShares = 300

      MicrogridBatteryWBNB - receiver

      receiversAllocPoints for user’s MicrogridBatteryWBNB = 1000

      totalReceiversAllocPoints for user’s = 1000

      last_distPoints[1][address(MicrogridBatteryWBNB)] = 50000

Next, malicious user calls `claimFor`, where the `rewards` for `receiver` are calculated using `_getDistributionRewards` as follows
```solidity
  function _getDistributionRewards(uint256 _id, address _receiver) internal view returns (uint256) {
    uint256 _points = last_distPoints[_id][_receiver];
    if (_points == 0) return 0;

    uint256 _distributionRewards = nft.individualShares(_id).mul(totalDistributePoints.sub(_points)).div(MULTIPLIER);
    uint256 _receiverAllocPoints = receiversAllocPoints[_id][_receiver];
    uint256 _totalReceiversAllocPoints = totalReceiversAllocPoints[_id];

    if (_totalReceiversAllocPoints == 0 && _receiver == address(this)) return _distributionRewards;

    return
      verifiedReceivers[_receiver] && _receiverAllocPoints > 0 && _totalReceiversAllocPoints > 0
        ? _distributionRewards.mul(_receiverAllocPoints).div(_totalReceiversAllocPoints)
        : 0;
  }
```
Here you can see that malicious user will receive `rewards` based on the new `individualShares` value - 3 times more than they should have.

In one option, the `attacker` can monitor the mempool in order to make a frontrun transaction that outputs rewards from `Farm` to `FusionRewardDistributor` (while sharply increasing the value of its `individualShares`).

An additional problem for the protocol would be that if, due to this situation, it turns out that `eSharePending < distributed`
```solidity
      esharePending = esharePending.sub(distributed);
```


**2. Via Split**

    Let's assume there are 2 attackers with same balances

      MicrogridNFT id

      individualShares = 100

      MicrogridBatteryWBNB - receiver

      receiversAllocPoints for user’s MicrogridBatteryWBNB = 1000

      totalReceiversAllocPoints for user’s = 1000

      last_distPoints[id][address(MicrogridBatteryWBNB)] = 50000

      MicrogridBatterySplitMyPosition

At the same time, on the contract `totalDistributePoints = 50000`.

Attacker1 puts 100 of his `individualShares` up for sale using the split method on `BatteryInteractSplitMyPosition`

```solidity
  function split(uint256 sharesAmount, uint256 pricePerShare) public nonReentrant {
    // Find user's microgrid token ID.
    uint256 usersMicrogridToken = microgridContract.tokenByWallet(msg.sender);

    // Requires
    require(usersMicrogridToken > 0, "You must own a Microgrid NFT.");
    require(sharesAmount <= microgridContract.individualShares(usersMicrogridToken), "You cannot split more shares than you own.");

    // Remove the sharesAmount from user's individualShares temporarily.
    uint256 currentShares = microgridContract.individualShares(usersMicrogridToken);
    uint256 newShares = currentShares - sharesAmount;
    microgridContract.setShares(newShares, usersMicrogridToken);

    // Add the sharesAmount temporarily to the Treasury wallet.
    uint256 treasuryMicrogridToken = microgridContract.tokenByWallet(treasury);
    uint256 treasuryCurrentShares = microgridContract.individualShares(treasuryMicrogridToken);
    uint256 treasuryNewShares = treasuryCurrentShares + sharesAmount;
    microgridContract.setShares(treasuryNewShares, treasuryMicrogridToken);

    // Add the shares and pricePerShare to the salesList mapping.
    ..........................
    }
```
Here new `individualShares` values (0 for Attacker1, 100 for Treasury) are written via the method `setShares` on `MicrogridNFT`
```solidity
  function setShares(uint256 amount, uint256 tokenId) external nonReentrant {
    require(_exists(tokenId), "Token does not exist");
    require(
      allowedBatteries[msg.sender],
      "Only batteries can set a tokenId's shares."
    );

    uint256 previousShares = individualShares[tokenId];

    individualShares[tokenId] = amount;
    totalShares -= previousShares;
    totalShares += amount;
    _updateRewardsAndPoints(tokenId);
  }
```
After adding, the `updateRewardsAndPonts` method is called.

New value on the contract `totalDistributePoints = 80000`.

However, the `compound` for the user does not occur (since `totalReceiversAllocPoints != 0`) and there is no update to the `last_distPoints` value either.

After this, Attacker2, through the `buyOrder` method on `BatteryInteractSplitMyPosition`, acquires 100 `individualShares` (now he has 200).
```solidity
  function buyOrder(uint256 orderId, uint256 sharesAmount) public payable nonReentrant {
    // Find microgrid token ID and current Shares.
    uint256 usersMicrogridToken = microgridContract.tokenByWallet(msg.sender);
    uint256 treasuryMicrogridToken = microgridContract.tokenByWallet(treasury);
    uint256 buyerCurrentShares = microgridContract.individualShares(usersMicrogridToken);
    uint256 treasuryCurrentShares = microgridContract.individualShares(treasuryMicrogridToken);

    .............................

    // Transfer shares.
    uint256 buyerNewShares = buyerCurrentShares + sharesAmount;
    microgridContract.setShares(buyerNewShares, usersMicrogridToken);

    uint256 treasuryNewShares = treasuryCurrentShares - sharesAmount;
    microgridContract.setShares(treasuryNewShares, treasuryMicrogridToken);

    // Emit event.
    emit SharesBought(orderId, sharesAmount, feeAmount + sellerAmount);
  }
```
Next, Attacker2 calls `claimFor`, receiving extra rewards.

The next step is to do this procedure in reverse order.

As a result, Attacker1 has 

    individualShares = 200
    
    last_distPoints[id][address(MicrogridBatteryWBNB)] = 50000 (as in the beginning)

After which Attacker1 also receives extra rewards.

We would also like to point out that with each `split` the `compound` is executed for Treasury (`totalReceiversAllocPoints == 0`), which leads to loss of user rewards.

## Recommendations

We recommend 

  - changing the logic for accounting and updating `last_distPoints`

  - add check that `eSharePending >= distributed`

  - reviewing logic with compound for Treasury



## <a id='C-12'></a>C-12. Calculation for `ExchangeRate` will result in wrong decimals

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WBNBBatteryInteract.sol#L1449

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1454

## Severity

**Impact:**
High, as it will result in wrong rate calculations

**Likelihood:**
High, as this will happen any time the user claim rewards

## Description

The method `_getExchangeRate` is implemented so that during calculations `Rate` is obtained with a decimals 1e18 times less than necessary.


Functions with this issue:
  - `WBNBBatteryInteract._getExchangeRate`
  - `WETHBatteryInteract._getExchangeRate`

## Recommendations

Change the code in the following way:

```diff
  function _getExchangeRate(address token, uint256 usdValue) internal view returns (uint256) {
    uint256 exchangeRate = microgridNFTDeposit.getExchangeRate(token);
    require(exchangeRate > 0, "not_listed");

    uint256 decimals = uint256(IERC20(token).decimals());

-   return (usdValue * 10**decimals / exchangeRate);
+   return (usdValue * 1e18 * 10**decimals / exchangeRate);
  }
```  



## <a id='C-13'></a>C-13. It's impossible for a user to claim his rewards, as `run` and `runFromUpkeep` will not pass `currentMinClaim` check

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WBNBBatteryInteract.sol#L1311

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WBNBBatteryInteract.sol#L1346

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1311

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1348

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WBNBBatteryInteract.sol#L896

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L896

## Severity

**Impact:**
High, because users will not receive rewards from the contract

**Likelihood:**
High, as this will happen any time the user claim rewards

## Description

The `run` method should be used by a user to receive his rewards. This won't ever work due to the following issues in the code implementation:

At the beginning of the method, a check is made that the value of rewards is not less than the amount of tokens (`currentMinClaim`) obtained from recalculating `minClaimAmount` denominated in USD. 
However, the external call to `claimFor` on `FusionRewardDistributor`, which is responsible for receiving rewards from the `farm` and further distribution, occurs after this check.

- Also, `claimFor` is implemented in such a way that if the parameter `_saveGas == true` (as specified in method `run` implementation), the call to `_tryClaimFarm` is not carried out.
  ```solidity
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

          eshare.safeTransfer(_receiver, rewards);

          if (!_saveGas) {
            emit Claim(_id, rewards);
          }
        }
      }
    }
  ```
  So checking of `currentMinClaim` will result in revert.

- At external call of method `getTotalRewards` on `FusionRewardDistributor`, the parameter `_receiver` must be `batteryContract` (not `address(this)`).

- The method `claimFor` on `FusionRewardDistributor` has 3 parameters (not 2, as specified in the code) - parameter `_receiver` is missing.

Functions with these issues:
  - `WBNBBatteryInteract.run`
  - `WBNBBatteryInteract.runFromUpkeep`
  - `WETHBatteryInteract.run`
  - `WETHBatteryInteract.runFromUpkeep`

## Recommendations

Add functionality to ensure that rewards are transfered from the `farm` and distributed before checking.

Add the method `batteryClaimFarm` in contract `FusionRewardDistributor`

```diff
+   function batteryClaimFarm() external {
+     require(_listOfReceiversInteractContracts.contains(msg.sender), "Caller is not ReceiversInteractContract");
+     _tryClaimFarm();
+     _distributeRewards();
+   }
```

Change the code in the following way:

```diff
    function run() public nonReentrant {
      // Find user's Microgrid token ID and current minimum claim amount.
      uint256 usersMicrogridToken = microgridContract.tokenByWallet(msg.sender);
      uint256 currentMinClaim = _getExchangeRate(address(eshareToken), minClaimAmount);

      // Requires and WBNB variable.
      require(usersMicrogridToken > 0, "You must own a Microgrid NFT.");
      require(batteryContract.checkBattery(usersMicrogridToken) == true, "Your Microgrid does not own this battery.");
+     fusionDistributorContract.batteryClaimFarm();
-     require(fusionDistributorContract.getTotalRewards(usersMicrogridToken, address(this)) >= currentMinClaim, "You don't have enough claimable rewards yet.");
+     require(fusionDistributorContract.getTotalRewards(usersMicrogridToken, address(batteryContract)) >= currentMinClaim, "You don't have enough claimable rewards yet.");
      require(lastClaimTime[usersMicrogridToken] + claimTimeLimit <= block.timestamp, "You have to wait for the claim time limit to pass.");
      IWBNB WBNB = IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

      // Establish initial balances.
      uint256 beforeBalanceEshare = eshareToken.balanceOf(address(this));

      // Claim from fusion reward distributor.
-     fusionDistributorContract.claimFor(usersMicrogridToken, true);
+     fusionDistributorContract.claimFor(usersMicrogridToken, address(batteryContract), true);

      // Get received Eshare amount and Sell 100% of it for WBNB.
      uint256 eshareSellAmount = eshareToken.balanceOf(address(this)) - beforeBalanceEshare;
      .....................
``` 
```diff
    function runFromUpkeep(address holder) public nonReentrant {
      // Find user's Microgrid token ID and current minimum claim amount.
      uint256 usersMicrogridToken = microgridContract.tokenByWallet(holder);
      uint256 currentMinClaim = _getExchangeRate(address(eshareToken), minClaimAmount);

      // Requires and WBNB variable.
      require(msg.sender == upkeepContract, "Only the Upkeep contract can use this function.");
      require(usersMicrogridToken > 0, "You must own a Microgrid NFT.");
      require(batteryContract.checkBattery(usersMicrogridToken) == true, "Your Microgrid does not own this battery.");
+     fusionDistributorContract.batteryClaimFarm();
-     require(fusionDistributorContract.getTotalRewards(usersMicrogridToken, address(this)) >= currentMinClaim, "You don't have enough claimable rewards yet.");
+     require(fusionDistributorContract.getTotalRewards(usersMicrogridToken, address(batteryContract)) >= currentMinClaim, "You don't have enough claimable rewards yet.");
      require(lastClaimTime[usersMicrogridToken] + claimTimeLimit <= block.timestamp, "You have to wait for the claim time limit to pass.");
      IWBNB WBNB = IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

      // Establish initial balances.
      uint256 beforeBalanceEshare = eshareToken.balanceOf(address(this));

      // Claim from fusion reward distributor.
-     fusionDistributorContract.claimFor(usersMicrogridToken, true);
+     fusionDistributorContract.claimFor(usersMicrogridToken, address(batteryContract), true);

      // Get received Eshare amount and Sell 100% of it for WBNB.
      uint256 eshareSellAmount = eshareToken.balanceOf(address(this)) - beforeBalanceEshare;
      .....................
``` 
```diff
    interface IFusionRewardDistributor {
-     function claimFor(uint256 tokenId, bool claimBefore) external;
+     function claimFor(uint256 tokenId, address receiver, bool claimBefore) external;
      function getTotalRewards(uint256 _tokenId, address _receiver) external view returns (uint256);
      function setReceiver(uint256 _id, uint256 _allocPoints) external;
+     function batteryClaimFarm() external;
    }
``` 



## <a id='C-14'></a>C-14. Wrong calculation in `buyOrder` increases the `refundAmount`

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol#L355

## Severity

**Impact:**
High, as this will lead to a monetary loss for protocol

**Likelihood:**
High, as this will happen any time the user buys order

## Description

The value of `refundAmount` in the method `buyOrder` calculates incorrectly.

## Recommendations

Change the code in the following way:

```diff
      ................
      // Refund overpay amount, if buyer overpaid.
      if (msg.value > sellerAmount + feeAmount) {
-       uint256 refundAmount = msg.value - sellerAmount + feeAmount;
+       uint256 refundAmount = msg.value - sellerAmount - feeAmount;
        payable(msg.sender).transfer(refundAmount);
      }
      ................
``` 



## <a id='C-15'></a>C-15. Missing a method for setting `MarketplaceContract`

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol

## Severity

**Impact:**
High, as this will restrict the functionality of contract

**Likelihood:**
High, as the contract cannot be used

## Description

The `MicrogridBatterySplitMyPositionInteract` is missing a method for setting `MarketplaceContract`. This leads to the impossibility of using the method `buyBattery`, and as a result, disabling contract functionality.

## Recommendations

Add a setter for `MarketplaceContract`. 

