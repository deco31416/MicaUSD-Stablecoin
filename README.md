![MicaUSD Stablecoin](https://github.com/deco31416/MicaUSD-Stablecoin/blob/main/public/header.svg)

# MicaUSD Stablecoin

![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-blue?logo=solidity&logoColor=white)

**[MicaUSD](https://github.com/deco31416/MicaUSD-Stablecoin)** is a stablecoin project developed with the goal of providing a stable and transparent solution for value exchange, adhering to international regulations, including the **MiCA** (Markets in Crypto-Assets Regulation) framework of the European Union.

This project is deployed on the **Binance Smart Chain Testnet** and is designed to ensure stability and security through a supply custody model controlled by audited and verified smart contracts. MicaUSD aims to be an example of transparency and trust in the world of stablecoins, incorporating robust security and governance standards.

**_walletSupplyCustodian:** The address of the wallet that will hold the supply custody.
```bash
 0x3f9de97cB91Fa3ca1ac000Ec5b9896a6E68FB1cb
 ```
**_initialSupply:** The initial supply of tokens to be minted. These are sent to the _walletSupplyCustodian.
```bash
1000
```
## Key Features

1. **Stablecoin adhering to international regulations**: MicaUSD is developed with the goal of complying with current laws and regulations, including **MiCA**, ensuring transparency, security, and governance.
2. **Supply Custody**: Through the `SupplyCustodian.sol` contract, the issuance and burning of tokens is managed securely and controlled, ensuring the stability of the token supply.
3. **Fee Control**: Adjustable minting and burning fees are incorporated through the contracts, facilitating adoption in various market conditions.
4. **Blacklist and Whitelist functionalities**: The `BaseStableToken.sol` contract allows addresses to be blocked or enabled to protect the network and maintain transparency.
5. **ERC-20 Standard Compliance**: MicaUSD is compatible with the ERC-20 standard, ensuring interoperability with other platforms and projects within the blockchain ecosystem.
6. **Robust Security**: The contracts are developed using `Ownable`, `ReentrancyGuard`, and `Pausable` to protect transactions and mitigate risks of re-entrancy and attacks.
7. **Upcoming Features**: The project will continue to improve with the implementation of emission orders, emission declarations, and more advanced features.

## Contracts

### 1. `SupplyCustodian.sol`
This contract manages the issuance and burning of tokens under strict custody rules. Key functionalities include:

- Token issuance with adjustable fees.
- Token burning under the control of the custody contract.
- Ability to adjust token prices and fees.
- Pausing operations when necessary.

### 2. `BaseStableToken.sol`
This contract handles the token itself, allowing it to be used as a stablecoin on the Binance Smart Chain Testnet. Key features include:

- ERC-20 token transfers.
- Blacklist and whitelist functionalities to ensure security and regulatory compliance.
- Minting and burning capabilities under the supervision of the custody contract.
- Full compatibility with ERC-20 compliant wallets and exchanges.

## Deployment

MicaUSD is currently deployed on the Binance Smart Chain Testnet for testing and development. The contracts are available for review and audit in the repository.

### Contracts on the Binance Smart Chain Testnet:

- **SupplyCustodian.sol**: Supply custody and fee control.
  
- **BaseStableToken.sol**: Main token contract with full ERC-20 functionality.

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

## Roadmap

- **Emission Orders:** Advanced tools to manage token issuance more efficiently.
  
- **Emission Declarations:** Automated reports on token issuance, aligned with international regulations.
  
- **Decentralized Governance:** Governance module for community participation in key protocol decision-making.

## License

This project is protected under the [Creative Commons Attribution 3.0 license](https://creativecommons.org/licenses/by/3.0/us/deed.en), and the underlying source code used to format and display this content is licensed under the [MIT license](https://github.com/deco31416/MicaUSD-Stablecoin/blob/main/LICENSE).

## Developed by

**[Deco31416](https://github.com/deco31416)**  
For more information, Visit: [deco31416.com](https://www.deco31416.com/)
