# [L-02] Missing zero address checks

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1031

## Severity

**Impact:**
Low, as it will not lead to the loss of funds or big restriction on the functionality of contract

**Likelihood:**
Low, as it requires a big error on owner's side

## Description

Contracts have address fields in multiple methods. These methods are missing address validations. Each address should be validated and checked to be non-zero. This is also considered
a best practice. A wrong user input or defaulting to the zero addresses for a missing input can lead to the contract needing to redeploy or wasted gas.

  Functions with missing zero address checks
  - `MicrogridNFTDeposit.constructor` 

## Recommendations

It is recommended to validate that each address input is non-zero.
