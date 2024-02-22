# [M-02] Missing checking that input array lengths are equal to each other

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L920

## Severity

**Impact:**
Medium, as it will not lead to the loss of funds

**Likelihood:**
Low, as it requires a big error on owner's side

## Description

The `setBonusTiers` method does not check if input array lengths are equal to each other.

## Recommendations

Add a check that input array lengths are equal to each other.
## Recommendations

Add  method `receive` to the contract `MarketplaceExchange`.
