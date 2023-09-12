# TokenSwap WEB3BRIDGE Task

TokenSwap is a smart contract that enables users to perform token swaps between two ERC20 tokens (tokenA and tokenB) in both directions, using the constant product market maker formula (x * y = k) to calculate the exchange rate for each swap. Additionally, it allows users to provide liquidity to and withdraw liquidity from the pool, and receive liquidity tokens in return. The contract also includes various view functions to get the prices and amounts of the tokens.

## Features

- Swap: Users can swap tokenA for tokenB or vice versa, by paying a small fee (0.3%) to the pool. The swap rate is determined by the ratio of the reserves of the two tokens in the pool, according to the formula x * y = k, where x and y are the reserves of tokenA and tokenB respectively, and k is a constant value.
- Mint: Users can provide liquidity to the pool by depositing both tokenA and tokenB, and receive liquidity tokens in proportion to their contribution. The initial liquidity is set by the geometric mean of the amounts of tokenA and tokenB deposited. The invariant k is also set by the product of the initial reserves. Subsequent liquidity providers must deposit tokenA and tokenB in the same ratio as the current reserves, or they will receive less liquidity tokens than expected.
- Burn: Users can withdraw liquidity from the pool by returning liquidity tokens, and receive tokenA and tokenB in proportion to their share of the pool. The invariant k must not decrease as a result of a withdrawal.
- View functions: Users can query the contract for various information, such as:
  - getPriceA: Get the price of tokenA in terms of tokenB
  - getPriceB: Get the price of tokenB in terms of tokenA
  - getAmountOut: Get the amount of output token for a given amount of input token
  - getAmountIn: Get the amount of input token for a given amount of output token

## Installation

To use TokenSwap, you need to have [hardhat](https://hardhat.org/) installed on your machine.

```bash
git clone https://github.com/PhantomOz/tSwapTS.git
cd tswapTS
npm install
```

## Configuration

You need to create a file named `.env` in the root directory of the project, and add your Infura project ID and your MetaMask mnemonic phrase as follows:

```bash
ALCHEMY_API_KEY=Alchemy Api key
SEPOLIA_PRIVATE_KEY=Private key
ETHERSCAN_API_KEY=EthersCAN API key
```

## Deployment

You can deploy TokenSwap to any Ethereum network (mainnet, testnet, or local) using Truffle commands. For example, to deploy to Sepolia testnet, you can run:

```bash
    npx hardhat deploy --network sepolia scripts/deploy.ts
```


## Testing

You can run tests for TokenSwap using Truffle commands. For example, to run tests on a local Ganache network, you can run:

```bash
npx hardhat test
```

This will run a series of tests to check the functionality and security of TokenSwap. You can find the test cases in the `test/Swap.ts` file.

## License

TokenSwap is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

## Details
You can view the following addresses on Ether Scan
tSwap Address: 0x01f148639cc1A66194dEa030A9EA17fF09D7b05A
Token A address: 0x35B01C567eb4C65330761c70be07D917b366197b
Token B address: 0xC7F3889c22D99D9257E2e9C7E9aD084Ae493C066