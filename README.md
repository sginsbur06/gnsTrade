# MorphexV3


- [About](#about)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
- [Audit Scope Details](#audit-scope-details)
  - [Roles](#roles)
  - [Known Issues](#known-issues)

# About 

MorhexV3 is a decentralized exchange (DEX) protocol. MorhexV3 allows you to swap cryptocurrencies immediately. You can switch between any two BEP-20 tokens directly with your wallet. This protocol was built using an automated market maker (AMM) model of concentrated liquidity. MorhexV3 trade pairs are represented by liquidity pools. These liquidity pools are filled with funds provided by users, who are called MorhexV3 (LPs).

A high-level overview of MorhexV3 main features includes swapping, yield farming, and staking. Now, let's dive into each functionality.

1. **Trading / Swapping**: With MorhexV3, users can trade BEP-20 tokens directly in a completely decentralized and censorship-resistant manner. Users do not need to deposit their tokens and wait for an order to fill. Instead, trades are executed immediately at market prices.

2. **Farming**: This is one of the core functionalities of MorhexV3, it's a way to generate rewards for MorhexV3. In simple terms, it involves lending your LP position to protocol. Liquidity providers earn Reward tokens for the proportion of the LP position that they stake. The more a user stakes, the more rewards they can reap.

For the development of MorhexV3, a protocol [PancakeSwap V3](https://github.com/pancakeswap/pancake-v3-contracts/tree/main/projects) , (commit 7d2cb5700651b77d140b81d00c561ef6fc4b9f8e) was chosen as a starting point.

In sum, PancakeSwap V3 has various functionalities that allow users to earn and maximize returns, making it one of the leading DEXs on the Binance Smart Chain network. As a DEX, it leverages its community for decision-making and development, rather than being controlled by a single entity, bringing decentralization to the fore.





The ⚡️ThunderLoan⚡️ protocol is meant to do the following:

1. Give users a way to create flash loans
2. Give liquidity providers a way to earn money off their capital

Liquidity providers can `deposit` assets into `ThunderLoan` and be given `AssetTokens` in return. These `AssetTokens` gain interest over time depending on how often people take out flash loans!

What is a flash loan? 

A flash loan is a loan that exists for exactly 1 transaction. A user can borrow any amount of assets from the protocol as long as they pay it back in the same transaction. If they don't pay it back, the transaction reverts and the loan is cancelled.

Users additionally have to pay a small fee to the protocol depending on how much money they borrow. To calculate the fee, we're using the famous on-chain TSwap price oracle.

We are planning to upgrade from the current `ThunderLoan` contract to the `ThunderLoanUpgraded` contract. Please include this upgrade in scope of a security review. 

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## Quickstart

```
git clone https://github.com/Cyfrin/6-thunder-loan-audit
cd 6-thunder-loan-audit
make 
```

# Usage

## Testing

```
forge test
```

### Test Coverage

```
forge coverage
```

and for coverage based testing: 

```
forge coverage --report debug
```

# Audit Scope Details

- Commit Hash: 8803f851f6b37e99eab2e94b4690c8b70e26b3f6
- In Scope:
```
#-- interfaces
|   #-- IFlashLoanReceiver.sol
|   #-- IPoolFactory.sol
|   #-- ITSwapPool.sol
|   #-- IThunderLoan.sol
#-- protocol
|   #-- AssetToken.sol
|   #-- OracleUpgradeable.sol
|   #-- ThunderLoan.sol
#-- upgradedProtocol
    #-- ThunderLoanUpgraded.sol
```
- Solc Version: 0.8.20
- Chain(s) to deploy contract to: Ethereum
- ERC20s:
  - USDC 
  - DAI
  - LINK
  - WETH

## Roles

- Owner: The owner of the protocol who has the power to upgrade the implementation. 
- Liquidity Provider: A user who deposits assets into the protocol to earn interest. 
- User: A user who takes out flash loans from the protocol.

## Known Issues

- We are aware that `getCalculatedFee` can result in 0 fees for very small flash loans. We are OK with that. There is some small rounding errors when it comes to low fees
- We are aware that the first depositor gets an unfair advantage in assetToken distribution. We will be making a large initial deposit to mitigate this, and this is a known issue
- We are aware that "weird" ERC20s break the protocol, including fee-on-transfer, rebasing, and ERC-777 tokens. The owner will vet any additional tokens before adding them to the protocol. 
