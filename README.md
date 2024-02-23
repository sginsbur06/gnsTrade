# [C-02] Logic of `deposit` under conditions of `Sacrifice` is not implemented

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1255

## Severity

**Impact:**
High, as this will lead to restriction on the functionality of protocol

**Likelihood:**
High, as this will happen any time the user try to deposit with sacrifice

## Description

The logic of the protocol assumes that in method `deposit` in cases `DepositType(depositType) == DepositType.BY_SACRIFICE` and `DepositType(depositType) == DepositType.BY_SACRIFICE_USD` a deposit will be carried out without the actual transfer of tokens (or BNB) from users to the contract `MicrogridNFT`.
The current version of the code does not implement this, and the transaction will revert.

## Recommendations

Change the code in the following way:

```diff

    if ((DepositType(depositType) == DepositType.BY_EMP_ETH_LP)) {
      empEthLpToken.transferFrom(tx.origin, address(microgridNFTContract), amount);

    } else if ((DepositType(depositType) == DepositType.DEFAULT)) {
      empToken.transferFrom(msg.sender, address(microgridNFTContract), amount);

    } else if ((DepositType(depositType) == DepositType.BY_UPEMP)) {
      upEmp.transferFrom(tx.origin, address(microgridNFTContract), amount);

    } else if ((DepositType(depositType) == DepositType.CURRENCY ||
      DepositType(depositType) == DepositType.CURRENCY_BY_TOKEN_ID) &&
      currency != address(0)) {
      (IERC20(currency)).transferFrom(msg.sender, address(microgridNFTContract), amount);

+   } else if ((DepositType(depositType) == DepositType.BY_SACRIFICE ||
+     DepositType(depositType) == DepositType.BY_SACRIFICE_USD)) {

    } else if (msg.value == 0){
      empToken.transferFrom(msg.sender, address(microgridNFTContract), amount);

    } else {
      payable(address(microgridNFTContract)).transfer(msg.value);
    }
    ...........
```
