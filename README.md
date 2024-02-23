# [H-02] Using `tx.origin` creates an opportunity for phishing attack

### Relevant GitHub Links

https://github.com/DeFi-Gang/emp-fusion-contracts/blob/main/contracts/fusion/MicrogridNFTDeposit.sol#L1314-L1321

## Severity

**Impact:**
High, as this will lead to a monetary loss for user

**Likelihood:**
Medium, as the attack is not easy to execute

## Description

The method `deposit` is implemented so that `transferFrom` contains `tx.origin` as parameter `from`.
```solidity
    if ((DepositType(depositType) == DepositType.BY_EMP_ETH_LP)) {
      empEthLpToken.transferFrom(tx.origin, address(microgridNFTContract), amount);

    } else if ((DepositType(depositType) == DepositType.DEFAULT)) {
      empToken.transferFrom(msg.sender, address(microgridNFTContract), amount);

    } else if ((DepositType(depositType) == DepositType.BY_UPEMP)) {
      upEmp.transferFrom(tx.origin, address(microgridNFTContract), amount);
    }
```
Using `tx.origin` is a dangerous practice as it opens the door to phishing attacks.

## Recommendations

To prevent `tx.origin` phishing attacks, `msg.sender` should be used instead of `tx.origin`.
