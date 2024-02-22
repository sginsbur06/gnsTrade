# [M-02] Oracle price is used without checking validity

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L932

## Severity

**Impact:**
Medium, it affects user assets only when the price feed oracle is in bad status

**Likelihood:**
Medium, it affects only when the price feed oracle is in bad status

## Description

The method `buyPoints` fetches data from Chainlink (or another price feed) with `IAggregator` and `latestAnswer`. To ensure accurate price usage, it's vital to regularly check the last update timestamp against a predefined delay. However, the current implementation lacks checks for the staleness of the price obtained from price feed. Without proper checks, consumers of protocol may continue using outdated, stale, or incorrect data if oracles are unable to submit and start a new round.

## Recommendations

Implement a mechanism to check the heartbeat of the price feed and compare it against a predefined maximum delay (`MAX_DELAY`). Adjust the `MAX_DELAY` variable based on the observed heartbeat.  It is recommended to implement checks to ensure that the price returned by price feed is not stale. 
