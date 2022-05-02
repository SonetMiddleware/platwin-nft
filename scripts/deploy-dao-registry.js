async function main() {
    const DAORegistry = await ethers.getContractFactory("DAORegistry");
    const daoRegistry = await upgrades.deployProxy(DAORegistry, []);
    console.log(daoRegistry.address);
    await daoRegistry.deployed();
    await daoRegistry.setWhiteList('0x0daB724e3deC31e5EB0a000Aa8FfC42F1EC917C5', true)
    await daoRegistry.setWhiteList('0x7c19f2eb9e4524D5Ef5114Eb646583bB0Bb6C8F8', true)
    await daoRegistry.setWhiteList('0x917be393EeF337f280eF2000430F16c1340CAcAd', true)
    await daoRegistry.setWhiteList('0xadDCa5C98b0fB6F8F9b4324D9f97F9Da55cbc3B2', true)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
