# [M-02]  Use of `transfer` might render BNB impossible to withdraw

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol#L344-L345

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol#L356

## Severity

**Impact:**
High, as it will lead to the loss of funds and restriction on the functionality of protocol

**Likelihood:**
Low, as it occurs only in this method

## Description

When withdrawing BNB, the `BatteryInteractSplitMyPosition` contract uses Solidity’s `transfer` function. This has some notable shortcomings when the withdrawer is a smart contract, which can render BNB impossible to withdraw. Specifically, the withdrawal will inevitably fail when:

  - The withdrawer smart contract does not implement a payable fallback function.
  - The withdrawer smart contract implements a payable fallback function which uses more than 2300 gas units.
  - The withdrawer smart contract implements a payable fallback function which needs less than 2300 gas units but is called through a proxy that raises the call’s gas usage above 2300.

## Recommendations

Recommendation is to stop using `transfer` in code and switch to using `call` instead. Additionally, note that the `sendValue` function available in OpenZeppelin Contract’s `Address` library can be used to transfer the withdrawn BNB without being limited to 2300 gas units.  



# [C-02] Wrong calculation in `buyOrder` increases the `refundAmount`

### Relevant GitHub Links
	
https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridBatterySplitMyPositionInteract.sol#L355

## Severity

**Impact:**
High, as this will lead to a monetary loss for protocol

**Likelihood:**
High, as this will happen any time the user buys order

## Description

The value of `refundAmount` in the method `buyOrder` calculates incorrectly.

## Recommendations

Change the code in the following way:

```diff
      ................
      // Refund overpay amount, if buyer overpaid.
      if (msg.value > sellerAmount + feeAmount) {
-       uint256 refundAmount = msg.value - sellerAmount + feeAmount;
+       uint256 refundAmount = msg.value - sellerAmount - feeAmount;
        payable(msg.sender).transfer(refundAmount);
      }
      ................
```

