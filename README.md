# [M-02] Lack of price validation in the method `setManualPrice`

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1151

## Severity

**Impact:**
High, as this will lead to a monetary loss for users

**Likelihood:**
Low, as it requires a malicious/compromised owner or a big error on his side

## Description

The `setManualPrice` method allows `owner` to set a price without any validation. This approach significantly increases the risk of protocol centralization.

## Recommendations

Add validation for owner set price using external oracles.
