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

# Main Changes

- renaming according to protocol style (MorhexV3)
- update solidity version to 0.8.24
- some code changes to meet the requirements of the new solidity version

# Audit Scope Details

- Commit Hash: 9deec1946489e7a2497282ed43b1ea5353d36538
- In Scope:
```
#-- masterchef-v3
#-- v3-core
#-- v3-lm-pool
#-- v3-periphery
```
- Solc Version: 0.8.24
- Chain(s) to deploy contract to: Lumia Mainnet

## Roles

- Owner: The owner of the protocol who has the power to upgrade the implementation. 
- Liquidity Provider: A user who deposits assets into the protocol's pools. 
- User: A user who makes swaps, takes out flash loans from the protocol.

## Known Issues

- We are aware that "weird" ERC20s break the protocol, rebasing, ERC-777 tokens etc. The owner will vet any additional tokens before adding them to the protocol. 
