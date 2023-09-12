// Import the required libraries and contracts
import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";


// Define some constants
const INITIAL_AMOUNT_A = ethers.parseEther("1000");
const INITIAL_AMOUNT_B = ethers.parseEther("2000");

async function main() {
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  console.log(`Deploying contracts with the account balance: ${await ethers.provider.getBalance(deployer.address)}`);

  // Deploy the tokens and the swap contract
  const TokenAFactory: ContractFactory = await ethers.getContractFactory(
    "TokenA"
  );
  const TokenBFactory: ContractFactory = await ethers.getContractFactory(
    "TokenB"
  );
  const TokenSwapFactory: ContractFactory = await ethers.getContractFactory(
    "TokenSwap"
  );
  const tokenA = (await TokenAFactory.deploy()) as Contract;
  const tokenB = (await TokenBFactory.deploy()) as Contract;
  

  // Wait for the contracts to be deployed
  await tokenA.waitForDeployment();
  await tokenB.waitForDeployment();
  
  console.log(`Token A address: ${tokenA.target}`);
  console.log(`Token B address: ${tokenB.target}`);


  const tokenSwap = (await TokenSwapFactory.deploy(
    tokenA.target,
    tokenB.target
  )) as Contract;
  await tokenSwap.waitForDeployment();

  // Log the contract addresses
  console.log(`Token Swap address: ${tokenSwap.target}`);

  // Mint some tokens for the deployer
  await tokenA.mint(deployer.address, INITIAL_AMOUNT_A);
  await tokenB.mint(deployer.address, INITIAL_AMOUNT_B);

  // Approve the swap contract to spend the deployer's tokens
  await tokenA.approve(tokenSwap.target, ethers.MaxUint256);
  await tokenB.approve(tokenSwap.target, ethers.MaxUint256);

  // Mint initial liquidity tokens for the deployer
  await tokenSwap.mint(INITIAL_AMOUNT_A, INITIAL_AMOUNT_B);

  // Log the deployer's balance of liquidity tokens
  console.log(
    `Deployer's balance of liquidity tokens: ${await tokenSwap.balanceOf(
      deployer.address
    )}`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
