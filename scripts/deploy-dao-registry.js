async function main() {
    const DAORegistry = await ethers.getContractFactory("DAORegistry");
    const daoRegistry = await upgrades.deployProxy(DAORegistry, []);
    console.log(daoRegistry.address);
    await daoRegistry.deployed();
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
