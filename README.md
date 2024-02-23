### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1072

## Severity

**Impact:**
Low, as it will not lead to the loss of funds or restriction on the functionality of protocol

**Likelihood:**
Low, as it occurs only in this method

## Description

The method `setAllowedCurrency` is implemented so that it missed the setting of  `allowedCurrencies[_token].token`.

## Recommendations

Change the code in the following way:

```diff
  function setAllowedCurrency(
    address _token,
    address _lpToken,
    uint256 _sharesPerEMP,
    bool _allowed
  ) public onlyOwner {
+   allowedCurrencies[_token].token = _token;
    allowedCurrencies[_token].lpToken = _lpToken; // The Cake-LP token for the primary trading pair for this token.
    allowedCurrencies[_token].sharesPerEMP = _sharesPerEMP; // Amount of microgrid shares allocated per $1 deposited.
    allowedCurrencies[_token].allowed = _allowed; // Only allowed = true tokens are able to be deposited.
  }
``` 
