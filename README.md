# [M-02] Missing checks for user's `Microgrid NFT` ownership of `battery`, `treasury` ownership of `Microgrid NFT`

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol#L240

## Severity

**Impact:**
High, as it will lead to the loss of funds and restriction on the functionality of protocol

**Likelihood:**
Low, as it occurs only in this method

## Description

The method `split` is implemented so that it missed checks that:
 - user's Microgrid NFT must own the battery
 - the treasury must own Microgrid NFT

This may result in the method `split` being used by a user who does not own the `battery`, causing financial loss to the protocol.

## Recommendations

Change the code in the following way:

```diff
  function split(uint256 sharesAmount, uint256 pricePerShare) public nonReentrant {
    // Find user's microgrid token ID.
    uint256 usersMicrogridToken = microgridContract.tokenByWallet(msg.sender);

    // Requires
    require(usersMicrogridToken > 0, "You must own a Microgrid NFT.");
+   require(batteryContract.checkBattery(usersMicrogridToken) == true, "Your Microgrid does not own this battery.");
    require(sharesAmount <= microgridContract.individualShares(usersMicrogridToken), "You cannot split more shares than you own.");

    // Remove the sharesAmount from user's individualShares temporarily.
    uint256 currentShares = microgridContract.individualShares(usersMicrogridToken);
    uint256 newShares = currentShares - sharesAmount;
    microgridContract.setShares(newShares, usersMicrogridToken);

    // Add the sharesAmount temporarily to the Treasury wallet.
    uint256 treasuryMicrogridToken = microgridContract.tokenByWallet(treasury);
+   require(treasuryMicrogridToken > 0, "Treasury must own a Microgrid NFT.");
    uint256 treasuryCurrentShares = microgridContract.individualShares(treasuryMicrogridToken);
    uint256 treasuryNewShares = treasuryCurrentShares + sharesAmount;
    microgridContract.setShares(treasuryNewShares, treasuryMicrogridToken);
    ....................
```  
