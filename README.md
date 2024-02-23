# [C-01] It's impossible for a user to claim his rewards, as `performUpkeep`, `claimFor`, `claimForMany` leaves rewards on contracts `BatteryInteractWETH` and `BatteryInteractWBNB`

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
