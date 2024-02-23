# [H-02] Exchange Rate can be manipulated

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1202

## Severity

**Impact:**
High, as this will lead to a monetary loss for protocol

**Likelihood:**
Medium, as it happens only in case of using the method as the main price feed

## Description

A malicious user can manipulate the protocol to get more shares from the `MicrogridNFTDeposit` than they should. The method `deposit` for calculations uses `getExchangeRate` - in which a possible option is to get the price through `getRateFromDex`. The calculation uses values of `reserve0` and `reserve1` in LP pair (`IPancakePair`) that can be manipulated by flashLoan.

## Recommendations

Add validation for price obtained from `getRateFromDex` using external oracles. 

