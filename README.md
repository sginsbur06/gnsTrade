# [C-02] Calculation for `finalAmount` will result in wrong decimals

### Relevant GitHub Links

https://github.com/sparkswapdao/emp-fusion-contracts/blob/main/contracts/fusion/MarketplaceInteract.sol#L932

## Severity

**Impact:**
High, as it will result in wrong points calculations

**Likelihood:**
High, as this will happen any time the user buys points

## Description

The method `buyPoints` is implemented so that 
  - during calculations `finalAmount` is obtained with a decimals 1e18 times large than necessary (in cases `token == address(empToken)`)
  - during calculations `finalAmount` is obtained with a decimals 1e18 times less than necessary (in cases `token != address(empToken)`)

## Recommendations

Change the code in the following way:

```diff
    // If token is being spent to purchase Marketplace Points.
   if (token != address(0)) {
    IERC20(token).transferFrom(msg.sender, address(marketplaceContract), amount);
    if (token == address(empToken)) {
-     uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token) * 1e18;
+     uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token);
      uint256 purchaseAmount = ((((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar) * 10000) * (calcRateEMP() / 1e18) / 10000;
      uint256 bonusPercent = getBonusPercent(purchaseAmount);
      uint256 finalAmount = ((((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar) * 10000) * (calcRateEMP() / 1e18) / 10000 * (bonusPercent * 10000) / 10000;
      marketplaceContract.addPoints(usersMicrogridId, finalAmount);
      emit PointsBought(usersMicrogridId, finalAmount);
    } else if (allowedCurrencies[token].exRateHelper == true) {
-     uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token) * 1e18;
+     uint256 currentPrice = microgridNFTDeposit.getExchangeRate(token);
      uint256 purchaseAmount = ((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar;
      uint256 bonusPercent = getBonusPercent(purchaseAmount);
      uint256 finalAmount = ((currentPrice * amount) / 1e18) * allowedCurrencies[token].pointsPerDollar * (bonusPercent * 10000) / 10000;
      marketplaceContract.addPoints(usersMicrogridId, finalAmount);
      emit PointsBought(usersMicrogridId, finalAmount);
    } else {
      int256 currentPrice = IAggregator(allowedCurrencies[token].priceAggregator).latestAnswer();
-     uint256 purchaseAmount = (((amount * (uint256(currentPrice) / 10 ** IAggregator(allowedCurrencies[token].priceAggregator).decimals())) / 1e18) * allowedCurrencies[token].pointsPerDollar);
+     uint256 purchaseAmount = ((amount * uint256(currentPrice) / 10 ** IAggregator(allowedCurrencies[token].priceAggregator).decimals()) * allowedCurrencies[token].pointsPerDollar);
      uint256 bonusPercent = getBonusPercent(purchaseAmount);
      uint256 finalAmount = (((amount * (uint256(currentPrice) / 10 ** IAggregator(allowedCurrencies[token].priceAggregator).decimals())) / 1e18) * allowedCurrencies[token].pointsPerDollar) * (bonusPercent *   10000) / 10000;
      marketplaceContract.addPoints(usersMicrogridId, finalAmount);
      emit PointsBought(usersMicrogridId, finalAmount);
    }

    // Else BNB is being spent.
    } else {
      payable(address(marketplaceContract)).transfer(msg.value);
      int256 currentPrice = IAggregator(aggregatorContract).latestAnswer();
-     uint256 purchaseAmount = (((msg.value * (uint256(currentPrice) / 10 ** IAggregator(aggregatorContract).decimals())) / 1e18) * pointsPerDollar);
+     uint256 purchaseAmount = ((msg.value * uint256(currentPrice) / 10 ** IAggregator(aggregatorContract).decimals()) * pointsPerDollar);
      uint256 bonusPercent = getBonusPercent(purchaseAmount);
      uint256 finalAmount = (((msg.value * (uint256(currentPrice) / 10 ** IAggregator(aggregatorContract).decimals())) / 1e18) * pointsPerDollar) * (bonusPercent * 10000) / 10000;
      marketplaceContract.addPoints(usersMicrogridId, finalAmount);
      emit PointsBought(usersMicrogridId, finalAmount);
    }
    
```
