# [H-02] `getExchangeRate` not take into account the possibility of `tokens` in `Pair` with different `decimals`

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1202

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/ExchangeRateHelper.sol#L906

## Severity

**Impact:**
High, as this will lead to a monetary loss for protocol

**Likelihood:**
Medium, as it happens only in case of using the method as the main price feed

## Description

In method `getExchangeRate` one of the possible options is to get the price through `getRateFromDex`. Implementation of `getExchangeRate` in a protocol assumes that it returns values with 1e18 `decimals`.

`getRateFromDex` to calculate `tokenPrice` uses values of `reserve0` and `reserve1` in LP pair (`IPancakePair`).
However, tokens in a pair may have different `decimals` values (and therefore - `reserve0`, `reserve1`). In this case, the calculation for `getExchangeRate` will be performed incorrectly.

A similar method `getRateFromDex` is also implemented in the contract `ExchangeRateHelper`.

## Recommendations

Add logic that takes into account the possibility of tokens with different `decimals` being in a pair.
