const { ethers } = require("hardhat");

async function main() {

  // Get the contract owner
  const contractOwner = await ethers.getSigners();
  console.log(`Deploying contract from: ${contractOwner[0].address}`);

  // Hardhat helper to get the ethers contractFactory object
  const User = await ethers.getContractFactory('User');

  // Deploy the contract
  console.log('Deploying User...');
  const user = await User.deploy();
  let userContractAddress = user.target;

  console.log(`User deployed to: ${userContractAddress}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
