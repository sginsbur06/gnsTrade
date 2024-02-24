# [H-02] Missing slippage checks, deadline check is not effective

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WBNBBatteryInteract.sol#L1338

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WBNBBatteryInteract.sol#L1374

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1340

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1378

## Severity

**Impact:**
High, as this will lead to a monetary loss for users

**Likelihood:**
Medium, as it is not expected to happen every time, but there are multiple attack paths here

## Description

The `run` (and `runFromUpkeep`) make a dangerous assumption about `slippage`, namely that there is not any. 
The `deadline` check is set to `block.timestamp + 120`, which means the deadline check is disabled.

Users can be frontrun and receive a worse price than expected when they initially submitted the transaction. There's no protection at all, no minimum return amount or deadline for the trade transaction to be valid which means the trade can be delayed by miners or users congesting the network, as well as being sandwich attacked - ultimately leading to loss of user funds.

Functions with these issues:
  - `WBNBBatteryInteract.run`
  - `WBNBBatteryInteract.runFromUpkeep`
  - `WETHBatteryInteract.run`
  - `WETHBatteryInteract.runFromUpkeep`

## Recommendations

Consider adding slippage protection, `amountOutMinimum` can be either set manually or calculated based on external oracles.
