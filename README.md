![MicaUSD Stablecoin](https://github.com/deco31416/MicaUSD-Stablecoin/blob/main/public/header.svg)

# MicaUSD

![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-blue?logo=solidity&logoColor=white)

> **MVP of a MICA-compliant stablecoin**

**[MicaUSD](https://github.com/deco31416/MicaUSD-Stablecoin)**  is a stablecoin project built on the European Union’s **MICA** (Markets in Crypto-Assets) regulatory framework. It combines innovation with stability to provide a stablecoin that maintains its value consistently over time while meeting stringent requirements for backing and transparency.

Designed to reliably and transparently preserve value, the MicaUSD protocol utilizes an architecture centered on an **Automated Market Maker (AMM)** and a system of **real-time price oracles.** This setup, supported by a monitoring backend, continuously adjusts the token’s value to sustain its peg.


This project is deployed on the **[MicaUSDT - Binance Smart Chain Testnet](https://testnet.bscscan.com/address/0x04c385f999dddc8be75a4384c26864abe496139a)** and is designed to ensure stability and security through a supply custody model controlled by a robust protocol. MicaUSD aims to be an example of transparency and trust in the world of stablecoins, incorporating robust security and governance standards.

**[WalletOwner](https://testnet.bscscan.com/address/0x0f15F0b08C48fd66F4B852683Bd3a5d7e28364f1)** The address of the wallet that will hold the supply custody.
```bash
 0x0f15F0b08C48fd66F4B852683Bd3a5d7e28364f1
 ```

 **[TokenContract](https://testnet.bscscan.com/token/0x04c385f999dddc8be75a4384c26864abe496139a)** The Token contract address.
```bash
 0x04C385F999dDDc8be75A4384C26864abE496139A
 ```

 **[_initialSupply:](https://testnet.bscscan.com/tx/0xd7dc047c1585c5d7256ba659a17edbdd68a2e8df276ac7ce386e068e011c1217)** The initial supply of tokens to be minted. These are sent to the **_walletSupplyCustodian**.
```bash
1000
```

**[_walletSupplyCustodian](https://testnet.bscscan.com/address/0x3f9de97cB91Fa3ca1ac000Ec5b9896a6E68FB1cb)** The address of the wallet that will hold the supply custody.
```bash
 0x3f9de97cB91Fa3ca1ac000Ec5b9896a6E68FB1cb
 ```

 **[SupplyCustodian](https://testnet.bscscan.com/address/0xeb70b9e122c5dc153628314ce4a7166f52f7df45)** The Supply Custodian contract address.
```bash
 0xeB70B9E122c5dC153628314Ce4a7166f52F7dF45
 ```

**PancakeSwap Testnet router**
```bash
 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3
 ```

 ## MicaUSD Issuance

The issuance of MicaUSD is done using several backup methods:

1. Minting with Stable Altcoins.
2. Minting with Variable Value Altcoins (in development).
3. Minting through Fiat (in integration).
4. Minting with Stable Value Coins.
5. Minting with Variable Value Coins (next development).

## Technical Architecture of the Protocol

The MicaUSD protocol is made up of interconnected smart contracts that ensure stability, transparency, and regulatory compliance. The main components include:

- **Governance**: Ensures secure and efficient governance of the protocol.
- MicaUSD: Defines the base structure of the token, ensuring a stable and auditable design.
- **SupplyManager**: Controls the issuance and burning of MicaUSD, verifying backing funds.
- **TreasureVault** and **EarningsVault**: They safeguard the protocol's reserves and profits.
- **ComplianceRegistry** and **KYC/AML Compliance**: Verify identity and regulatory compliance.
- **FiatReserveRegistry**: Updates fiat transactions on the blockchain.
- **AMM and StableRouter**: They facilitate automatic swaps and arbitrage, ensuring price stability.
- **PriceOracles**: They offer real-time pricing to maintain the stability of the system.
- **RiskManager and EmergencyShutdown**: Monitor and protect the system in case of compromise.
- **UpgradeabilityProxy**: Allows for future upgrades without interruption.
  
## Backend Functionality

The backend is critical to MicaUSD, as it supports:

1. Verification of fiat payments.
2. Supervision and updating of price oracles.
3. KYC/AML compliance.
4. Communication and registration in blockchain.
5. Fee management and risk strategies.

## Incentives for Liquidity Providers

To encourage participation, MicaUSD offers rewards to liquidity providers through the **LiquidityMiningIncentives** contract, calculating rewards based on the number of tokens contributed and the duration in the pool.

## Use Cases

1. **Stable Payments**: Ideal for secure transactions without volatility.
2. **Savings**: A safe asset for storing value.
3. **Exchange in DeFi**: Facilitates the exchange and arbitrage of assets.
4. **Institutional Advantages**: MICA compliance for high-volume operations.

## Project Roadmap

1. **Phase 1**: Initial development on Testnet, governance testing.
2. **Phase 2**: Implementation of audit and transparency modules.
3. **Phase 3**: Complete backend development and MICA compliance on Testnet.
4. **Phase 4**: Activation of liquidity incentives and continuous improvements.

## Future Projections

The development of MicaUSD will continue to improve its stability and adapt to regulatory changes, with a focus on:

- Minteo integration for fiat and variable altcoins.
- AMM optimization and arbitrage strategies.
- Implementation of staking and additional rewards.
- Audits and validation for ongoing compliance.

## Frequently Asked Questions (FAQs)

1. **What sets MicaUSD apart from other stablecoins?** 
MICA compliance, transparency in reserves and auditability in blockchain.

2. **How is MicaUSD backed?** 
 For fiat and crypto reserves, audited in **FiatReserveRegistry** and **TreasureVault**.

3. **Is it possible to verify reservations?** 
 Yes, the protocol allows you to verify reservations on the blockchain using the **ComplianceRegistry**.

## Final Thoughts

MicaUSD is designed as a robust, MICA-compliant stablecoin, with an advanced technical structure and auditing and transparency capabilities that ensure trust and security for its users.

## Deployment

MicaUSD is currently deployed on the Binance Smart Chain Testnet for testing and development. The contracts are available for review and audit in the repository.

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/MicaUSD-stablecoin.git
2. Install the dependencies:
   ```bash
   npm install
3. Deploy the contracts on the Binance Smart Chain Testnet using Hardhat:
   ```bash
   npx hardhat run scripts/deploy.js --network bscTestnet

## License

This project is protected under the [Creative Commons Attribution 3.0 license](https://creativecommons.org/licenses/by/3.0/us/deed.en), and the underlying source code used to format and display this content is licensed under the [MIT license](https://github.com/deco31416/MicaUSD-Stablecoin/blob/main/LICENSE).

## Developed by

**[Deco31416](https://github.com/deco31416)**  
For more information, Visit: [deco31416.com](https://www.deco31416.com/)
