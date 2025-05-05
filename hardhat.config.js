require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    localhost8546: {
      url: "http://127.0.0.1:8546"
    }
  },
  paths: {
    artifacts: "./public/artifacts",
  }
};
