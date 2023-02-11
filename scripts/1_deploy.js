require('@nomiclabs/hardhat-ethers');

const hre = require('hardhat');


const CollectionBuildName = "Vesting";

const proxyType = { kind: "uups" };

const decimals = 10**18;

async function main() {
    const[deployer] = await hre.ethers.getSigners();

    console.log("============================\n\r");
    console.log("Deploying contracts with account : " , deployer.address);
    console.log("Account balance: " , ((await deployer.getBalance()) / decimals).toString());

    console.log("==========================\n\r");

    const CollectionFactory = await hre.ethers.getContractFactory(CollectionBuildName);
    const CollectionArtifact = await hre.artifacts.readArtifact(CollectionBuildName);
    const TokenDeploy = await CollectionFactory.deploy("0xB538424C1930020b7E0cb7548F5Ad55fb2D8f29D");

    await TokenDeploy.deployed();

    console.log(`${CollectionArtifact.contractName} contract address: ${TokenDeploy.address}`);

    console.log("=============================\n\r");

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1);
    })