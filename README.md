

# [C-02] Calculation in `addPoints` reduces the user's balance

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/FusionRewardDistributor.sol

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
Moreover, the update occurs only in the case of `totalReceiversAllocPoints == 0` (if the user does not have a `Battery receiver`)
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

