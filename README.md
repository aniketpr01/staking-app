# Staking App

This app is a staking application built on the Ethereum blockchain using the Solidity programming language and the Hardhat development framework.

## Features

- Allows users to stake their Ethereum tokens in order to earn rewards
- Includes a user interface for easy interaction with the smart contract
- Utilizes the Hardhat framework for local development and testing
- Locks tokens for a specified period of time in order to net rewards
- Locked tokens can be used for a specific action, such as participating in a voting process or accessing premium features

## Getting Started

###### Prerequisites

- Node.js and npm
- Hardhat
- A local Ethereum network (such as Hardhat's built-in network)

###### Installation

1. Clone the repository
> git clone https://github.com/aniketpr01/staking-app
2. Install dependencies
> npm install
3. Compile the smart contract
> npx hardhat compile
4. Run the tests
> npx hardhat test
5. Start the local network
> npx hardhat node
6. Deploy the smart contract
> npx hardhat run scripts/00-deploy-reward-token.js --network localhost
> npx hardhat run scripts/01-deploy-staking.js --network localhost

## Note
- Make sure you are using the latest version of the solidity and hardhat
- Do the testing and review of the smart contract on various testnet before deploying on mainnet
- Securely store your private key if using testnet or mainnet
- Be aware of the gas fees.
- Understand the terms and conditions of the specific action that can be done with the locked tokens.

