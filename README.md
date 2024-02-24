# [C-02] Calculation for `ExchangeRate` will result in wrong decimals

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WBNBBatteryInteract.sol#L1449

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/WETHBatteryInteract.sol#L1454

## Severity

**Impact:**
High, as it will result in wrong rate calculations

**Likelihood:**
High, as this will happen any time the user claim rewards

## Description

The method `_getExchangeRate` is implemented so that during calculations `Rate` is obtained with a decimals 1e18 times less than necessary.


Functions with this issue:
  - `WBNBBatteryInteract._getExchangeRate`
  - `WETHBatteryInteract._getExchangeRate`

## Recommendations

Change the code in the following way:

```diff
  function _getExchangeRate(address token, uint256 usdValue) internal view returns (uint256) {
    uint256 exchangeRate = microgridNFTDeposit.getExchangeRate(token);
    require(exchangeRate > 0, "not_listed");

    uint256 decimals = uint256(IERC20(token).decimals());

-   return (usdValue * 10**decimals / exchangeRate);
+   return (usdValue * 1e18 * 10**decimals / exchangeRate);
  }
``` 
