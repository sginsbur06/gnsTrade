# [H-02] Incorrect `path` array length specified

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1335-L1338

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1373-L1376

## Severity

**Impact:**
Medium, as no value will be lost but the contract functionality will be limited

**Likelihood:**
High, as the functions will just revert every time

## Description

The methods `run` and `runFromUpkeep` have incorrectly specified `path` arrays lengths.

## Recommendations

Change the code in the following way:

```diff
-     address[] memory path = new address[](2);
+     address[] memory path = new address[](3);
      path[0] = address(eshareToken);
      path[1] = address(WBNB);
      path[2] = address(WETH);
```
