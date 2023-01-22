const { ethers, network } = require("hardhat");

const { CRYPTO_DEV_TOKEN_CONTRACT_ADDRESS } = require("../constants");

const {developmentChains} = require("../helper-hardhat-config");

async function main() {
  console.log("Deploying DEX contract")

  const cryptoDevTokenAddress = CRYPTO_DEV_TOKEN_CONTRACT_ADDRESS;
  /*
  A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
  so exchangeContract here is a factory for instances of our Exchange contract.
  */
  const exchangeContract = await ethers.getContractFactory("Exchange");

  // here we deploy the contract
  const deployedExchangeContract = await exchangeContract.deploy(
    cryptoDevTokenAddress
  );
  await deployedExchangeContract.deployTransaction.wait(10);

  // print the address of the deployed contract
  console.log("Exchange Contract Address:", deployedExchangeContract.address);
  console.log("--------------------------")
  
  //  2. Verify on Etherscan, if it's Goerli
  const args = [CRYPTO_DEV_TOKEN_CONTRACT_ADDRESS]

  if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
    console.log("Verifying on GoerliEtherscan...")
    await verify(deployedExchangeContract.address, args)
    //  it takes address and args of the S/C as parameters
    console.log("-------------------------------")
  }
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });