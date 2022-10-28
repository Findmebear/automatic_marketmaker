require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    lu_eth: {
      url: 'http://vitalik.cse.lehigh.edu:8545',
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};

// https://github.com/Findmebear/LehighWeb3 

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

// https://hardhat.org/tutorial/creating-a-new-hardhat-project


//https://github.com/Findmebear/LehighWeb3/blob/development/contracts/CreatePost.sol