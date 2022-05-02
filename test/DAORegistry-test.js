const {expect} = require("chai");

describe('Platwin NFT Market', function () {
    let nft, registry;
    let owner;
    it('init', async () => {
        const PlatwinMEME2WithoutRPC = await ethers.getContractFactory('PlatwinMEME2WithoutRPC');
        nft = await PlatwinMEME2WithoutRPC.deploy();
        const DAORegistry = await ethers.getContractFactory('DAORegistry');
        registry = await upgrades.deployProxy(DAORegistry, []);
        owner = await ethers.getSigner();
        await nft.mint(owner.address, 'asadfafafasadfafa');
    });
    it('check whitelist', async () => {
        await registry.setWhiteList(nft.address, true);
        expect(await registry.whitelist(nft.address)).to.eq(true);
    });
    it('create dao', async () => {
        await registry.createDao(nft.address, 'Platwin MEME Test DAO', '', '@suger');
        expect(await registry.daoList(nft.address)).to.eq(true);
    })
});