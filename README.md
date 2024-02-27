# [C-02] Accounting and updating `last_distPoints` allow malicious users to receive additional rewards

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



