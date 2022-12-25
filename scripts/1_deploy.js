require('@nomiclabs/hardhat-ethers');

const hre = require('hardhat');


const CollectionBuildName = "Collection";

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
    const CollectionContract = await hre.upgrades.deployProxy(CollectionFactory, proxyType);

    await CollectionContract.deployed();

    console.log(`Collection contract address :  ${CollectionContract.address}`);
    implementationAddress = await hre.upgrades.erc1967.getImplementationAddress(CollectionContract.address);
    console.log(`${CollectionArtifact.contractName} implementation address: ${implementationAddress}`);

    console.log("=============================\n\r");

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1);
    })