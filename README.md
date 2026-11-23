# 🛡️ Barney Guardian

**A standalone, decentralized Safety Module and Governance layer for the Barney Ecosystem.**

> ⚠️ **Project Status: Stealth & Independent**  
> Barney Guardian is currently designed as a **completely separate, complementary protocol**. The core `Barney StableCoin` (CoinEngine) has no awareness of this repository's existence. Guardian operates independently to build a liquidity backstop and decentralized governance structure. Any connection to the CoinEngine will happen in a future, explicit integration phase.

---

## 📖 Overview

Barney Guardian is a three-part protocol designed to provide a **first-loss capital backstop** and decentralized parameter management. It borrows architectural concepts from Aave's Safety Module and OpenZeppelin's Timelock governance.

Because it is built from scratch and operates independently, it can be audited, tested, and deployed without altering or risking the core stablecoin infrastructure. 

## 🏗️ Architecture

The protocol is split into three core, modular contracts:

### 1. `GuardianGovernance.sol`
A robust `TimelockController` that manages all critical protocol parameters. 
*   **Why it matters:** Prevents centralized rug-pulls. Any changes to cooldowns, reward rates, or slashing execution require a mandatory delay, giving the community time to react.

### 2. `GuardianStaking.sol` (The Safety Module)
An Aave-style staking pool where users deposit an underlying asset (e.g., `BSC` or a designated safety token).
*   **Rewards:** Stakers earn yield for providing liquidity.
*   **Cooldown Mechanism:** To prevent bank runs during a crisis, users must initiate a `requestWithdrawal()` and wait for a strict `cooldownPeriod` (e.g., 10 days) before funds can be withdrawn.
*   **Slashing Risk:** In the event of a protocol shortfall, stakers' funds can be slashed (up to a certain limit) to cover bad debt.

### 3. `GuardianSafetyModule.sol` (The Bridge)
The orchestrator contract that acts as the bridge between external protocols and the `GuardianStaking` pool. 
*   Currently, it sits idle. 
*   In a future integration, a protocol (like the Barney CoinEngine) could call `coverShortfall()` on this contract to trigger a pro-rata slashing event across all stakers.

---

## 🚀 Getting Started

This project uses [Foundry](https://book.getfoundry.sh/) for smart contract development and testing.

### Prerequisites
*   [Foundry installed](https://book.getfoundry.sh/getting-started/installation)
*   Git

### Installation & Build

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/barney-guardian.git
cd barney-guardian

# Install OpenZeppelin dependencies
forge install OpenZeppelin/openzeppelin-contracts --no-commit

# Compile the contracts
forge build