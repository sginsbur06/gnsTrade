# [C-06] Mint to an incorrectly specified address makes it impossible to buy a Battery NFT

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
