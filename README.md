
# [C-02] Calculation in `addPoints` reduces the user's balance.

### Relevant GitHub Links
	
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceExchange.sol#L100

## Severity

**Impact:**
High, as this will lead to a monetary loss for users

**Likelihood:**
High, as this will happen any time the user buys points

## Description

The method `addPoints` calculates incorrectly. When adding a `purchaseAmount` it reduces the user's balance.

## Recommendations

Change the code in the following way:

```diff
  function addPoints(uint256 microgridId, uint256 purchaseAmount) external {
    require(allowedCreditors[msg.sender] == true, "Only allowed creditors can add points.");
-   userBalance[microgridId] -= purchaseAmount;
+   userBalance[microgridId] += purchaseAmount;
  }
```

# [H-02] Missing method `receive` in contract.

### Relevant GitHub Links
	
https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceExchange.sol

## Severity

**Impact:**
Medium, as no value will be lost but the contract functionality will be limited

**Likelihood:**
High, as the function will just revert every time

## Description

The contract `MarketplaceExchange` is missing a method `receive`. This makes it impossible to receive BNB from the contract `MarketplaceInteract`, which violates the functionality of the method `buyPoints`.

## Recommendations

Add  method `receive` to the contract `MarketplaceExchange`.
