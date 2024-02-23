# [C-02] Wrong calculation for `amountWithBonus` may lead to loss of user funds

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1255

## Severity

**Impact:**
High, as it will result in wrong deposit calculations and loss of user funds

**Likelihood:**
High, as this will happen any time the user deposit

## Description

The method `deposit` in case of `DepositType(depositType) == DepositType.BY_SACRIFICE_USD` uses `currentPrice` of `empToken`. But calculations are implemented incorrectly.

Also, in cases `DepositType(depositType) == DepositType.CURRENCY` or `DepositType(depositType) == DepositType.CURRENCY_BY_TOKEN_ID`, there may be a situation that 
`getExchangeRate(address(empToken)) > getExchangeRate(address(currency))`. As a result of calculations, `currentPrice == 0`.

This can lead to loss of user funds.

## Recommendations

Change the code in the following way:

```diff
    if (DepositType(depositType) == DepositType.DEFAULT ||
      DepositType(depositType) == DepositType.BY_TOKEN_ID ||
      DepositType(depositType) == DepositType.FOR_NEW_USER) {
      amountWithBonus = (amountWithBonus * 10000) * (calcRateEMP() / 1e18) / 10000;

    } else if (DepositType(depositType) == DepositType.BY_SACRIFICE) {
      amountWithBonus = (amountWithBonus * allowedSacrifices[msg.sender].sacMultiplier) / 10000;

    } else if (DepositType(depositType) == DepositType.BY_SACRIFICE_USD) {
      uint256 currentPrice = (getExchangeRate(address(empToken)));
-     amountWithBonus = (((amountWithBonus * currentPrice) / 1e18) * allowedSacrifices[msg.sender].sacMultiplier) / 10000;
+     amountWithBonus = (((amountWithBonus / currentPrice) / 1e18) * allowedSacrifices[msg.sender].sacMultiplier) / 10000; 

    } else if ((DepositType(depositType) == DepositType.BY_UPEMP)) {
      amountWithBonus = (upEmp.calculatePrice() / 1e18) * amountWithBonus;

    } else if ((DepositType(depositType) == DepositType.BY_EMP_ETH_LP)) {
      amountWithBonus = ((amountWithBonus * 2 * 1e18 * empToken.balanceOf(address(empEthLpToken)) / empEthLpToken.totalSupply() / 1e18) * 10000) * (calcRateEMP() / 1e18) / 10000;
            
    } else if (DepositType(depositType) == DepositType.CURRENCY ||
      DepositType(depositType) == DepositType.CURRENCY_BY_TOKEN_ID) {
      int256 currentPrice = 0;
      uint256 _sharesPerEMP = sharesPerEMP;

      if (currency == address(0)) {
-      currentPrice = (int256(getExchangeRate(currency))) / (int256(getExchangeRate(address(empToken))));
+      currentPrice = (int256(getExchangeRate(currency) * 1e18)) / (int256(getExchangeRate(address(empToken))));
      } else {
-      currentPrice = (int256(getExchangeRate(currency))) / (int256(getExchangeRate(address(empToken))));
+      currentPrice = (int256(getExchangeRate(currency) * 1e18)) / (int256(getExchangeRate(address(empToken))));
        _sharesPerEMP = allowedCurrencies[currency].sharesPerEMP;
      }

      amountWithBonus= (amountWithBonus * ((uint256(currentPrice)) * _sharesPerEMP) / 1e18) / 1e18;
    }   
```  
