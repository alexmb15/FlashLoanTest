# ERC3156 Flash Loan Contracts

This repository contains Solidity contracts implementing ERC3156 Flash Loans along with tests.

## Contracts

### MyStableToken.sol

This contract implements a simple ERC20 token named MyStableToken with the symbol USDM and an initial supply of 1,000,000 tokens.

### FlashLender.sol

This contract acts as a lender for MyStableToken. It provides functions to lend tokens to borrowers and retrieve tokens from borrowers.

### FlashBorrower.sol

This contract represents a borrower for MyStableToken. It interacts with FlashLender to borrow tokens, perform actions depending on data, and return the borrowed tokens.

## Usage

1. Deploy the contracts to a Ethereum-compatible blockchain network.
2. Interact with the contracts using Ethereum wallets or scripts.
3. Ensure that appropriate permissions and allowances are set for borrowing and lending tokens.
4. Follow the ERC3156 standard for flash loan execution.

## Testing

To run tests, you'll need Hardhat and a development blockchain environment set up. Follow these steps:

1. Install dependencies:

npm install

2. Compile contracts:

npx hardhat compile

3. Run tests:

npx hardhat test


Ensure all tests pass before deploying the contracts to a live network.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

