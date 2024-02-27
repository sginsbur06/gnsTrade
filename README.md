# [C-02] Calculation in `addPoints` reduces the user's balance

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFT.sol

## Severity

**Impact:**
High, as this will lead to a monetary loss for users

**Likelihood:**
High, as this will happen any time the user buys points

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
  1. The user has
      - `MicrogridNFT id = 1`
      - `individualShares = 100`
      - `MicrogridBatteryWBNB - receiver`
      - `receiversAllocPoints for user’s MicrogridBatteryWBNB = 1000`
      - `totalReceiversAllocPoints for user’s = 1000`
      - `last_distPoints[1][address(MicrogridBatteryWBNB)] = 50000`

At the same time, on the contract `totalDistributePoints = 50000`.

The user adds another `200 shares` via `deposit` on the `MicrogridNFTDeposit` contract (`addSharesByDeposit` on `MicrogridNFT`)
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

However, the `compound` for the user does not occur (since `totalReceiversAllocPoints != 0`) and there is no update to the `last_distPoints` value either.

   
    
  The user ha
      - `individualShares = 300`
      - `MicrogridBatteryWBNB - receiver`
      - `receiversAllocPoints for user’s MicrogridBatteryWBNB = 1000`
      - `totalReceiversAllocPoints for user’s = 1000`
      - `last_distPoints[1][address(MicrogridBatteryWBNB)] = 50000`


  1.  New values
      - `MicrogridNFT id = 1`
      - `individualShares = 100`
      - `MicrogridBatteryWBNB - receiver`
      - `receiversAllocPoints for user’s MicrogridBatteryWBNB = 1000`
      - `totalReceiversAllocPoints for user’s = 1000`
      - `last_distPoints[1][address(MicrogridBatteryWBNB)] = 50000`

Next, the user calls `claimFor`, where the `rewards` for `receiver` are calculated using `_getDistributionRewards` as follows
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
Here you can see that the user will receive `rewards` based on the new `individualShares` value - 3 times more than they should have.

In one option, the `attacker` can monitor the mempool in order to make a frontrun transaction that outputs rewards from `Farm` to `FusionRewardDistributor` (while sharply increasing the value of its `individualShares`).

An additional problem for the protocol would be that if, due to this situation, it turns out that `eSharePending < distributed`
```solidity
      esharePending = esharePending.sub(distributed);
```

