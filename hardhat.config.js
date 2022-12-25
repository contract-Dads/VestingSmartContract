require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-web3");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-contract-sizer");

const { InfuraKey, mnemonic, Wallet, BscScanApiKey, EtherscanApiKey, PrivateKey, PrelivePK, PolygonScanApiKey } = require('./.secret.json');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("balance", "Prints an account's balance")
  .addParam("account", "The account's address")
  .setAction(async (taskArgs) => {
    const account = web3.utils.toChecksumAddress(taskArgs.account);
    const balance = await web3.eth.getBalance(account);

    console.log(web3.utils.fromWei(balance, "ether"), "ETH");
  });

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // url: "http://127.0.0.1:8545/",
      // accounts: ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"]
      // forking: {
      //   url: `https://rinkeby.infura.io/v3/${InfuraKey}`
      // }
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${InfuraKey}`,
      chainId: 4,
      gas: 5500000,
      accounts: { mnemonic: mnemonic },
      from: Wallet
    },
    bsctest: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gas: 8812388,
      gasPrice: 10000000000,
      accounts: { mnemonic: mnemonic },
    },
    mainnet: {
      url: "https://speedy-nodes-nyc.moralis.io/91997e089e13b6fc9afdc40b/bsc/mainnet",
      chainId: 56,
      gasPrice: 4000000000,
      accounts: PrivateKey
    },
    mumbai: {
     // url: "https://rpc-mumbai.maticvigil.com/v1/946e0dd5dfac58922ac1e24937df5b9af792756b",
      // url: "https://api-testnet.polygonscan.com/",
       url: "https://rpc-mumbai.matic.today",

      // url: "https://matic-mumbai.chainstacklabs.com/",
      // url: "https://polygon-mumbai.g.alchemy.com/v2/9CN4PT3HCTBUDFCABQX5GXVCNVIZZT97NF",
      // url: "https://speedy-nodes-nyc.moralis.io/ae57f718777aea44f270358f/polygon/mumbai",

      chainId: 80001,
      gasPrice: 20000000000,
      networkCheckTimeout: 240000,
      accounts: { mnemonic: mnemonic }
    },
  },
  etherscan: {
    apiKey: BscScanApiKey
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      // evmVersion: "byzantium"
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: true,
    runOnCompile: false,
    strict: false,
  },
  mocha: {
    timeout: 600000
  }
};
