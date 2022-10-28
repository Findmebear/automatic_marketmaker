const hre = require("hardhat");

async function main() {
  const AMM_Contract = await hre.ethers.getContractFactory("Exchange");
  const deployContract = await AMM_Contract.deploy();
  await lock.deployed();

  console.log(
    `Automatic Market Maker deployed to: ${deployContract.address} \n
    Gas price: ${hre.ethers.utils.formatUnits(hre.ethers.provider.getGasPrice(), 'gwei')} gwei \n`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
