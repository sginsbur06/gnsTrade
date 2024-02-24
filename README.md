# [C-02] It's impossible for a user to claim his rewards, as `run` and `runFromUpkeep` will not pass `currentMinClaim` check

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

