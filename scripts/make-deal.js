async function main() {
    const multiplier = ethers.BigNumber.from('1000000000000000000');
    const emptyAddr = ethers.utils.getAddress("0x0000000000000000000000000000000000000000");

    const PlatwinMEME2WithoutRPC = await ethers.getContractFactory("PlatwinMEME2WithoutRPC");
    let meme2WithoutRPC = await PlatwinMEME2WithoutRPC.attach('0x0daB724e3deC31e5EB0a000Aa8FfC42F1EC917C5');
    const Market = await ethers.getContractFactory("Market");
    let market = await Market.attach('0xc7225694A6Fe8793eEf5B171559Cbd245E73b987');
    let [owner, user] = await ethers.getSigners();
    const DealRouter = await ethers.getContractFactory("DealRouter");
    let router = await DealRouter.attach('0xd79Ffe5F296D547f0CB066b3c91dE0361e7e522b');
    const TestERC20 = await ethers.getContractFactory("TestERC20");
    let testERC20 = await TestERC20.attach('0x132Eb6C9d49ACaB9cb7B364Ea79FdC169Ef90e59');
    await testERC20.transfer(user.address, multiplier.mul(1000))
    await testERC20.approve(router.address, multiplier.mul(multiplier));
    await testERC20.connect(user).approve(router.address, multiplier.mul(multiplier));
    // mint nft
    let tokenIndex = await meme2WithoutRPC.tokenIndex();
    await meme2WithoutRPC.mint(owner.address, 'bafybeig72b5gegkt5qaoqev6sm2comsm6cs5qxwv54oq6on2hqzxs2wr6m');
    let tokenId1 = tokenIndex;
    await meme2WithoutRPC.mint(user.address, 'bafybeig72b5gegkt5qaoqev6sm2comsm6cs5qxwv54oq6on2hqzxs2wr6m');
    let tokenId2 = tokenIndex + 1;
    await meme2WithoutRPC.setApprovalForAll(market.address, true);
    await meme2WithoutRPC.connect(user).setApprovalForAll(market.address, true);
    // make order
    let minPrice = multiplier;
    let maxPrice = multiplier.mul(2);
    let startBlock = ethers.BigNumber.from(await ethers.provider.getBlockNumber()).add(100);
    let duration = 100;
    let orderId = await market.ordersNum();
    await market.makeOrder(true, meme2WithoutRPC.address, tokenId1, 1, testERC20.address, minPrice, maxPrice, startBlock,
        duration);
    let orderId1 = orderId++;
    await market.connect(user).makeOrder(true, meme2WithoutRPC.address, tokenId2, 1, emptyAddr, minPrice.div(100),
        maxPrice.div(100), startBlock, duration);
    let orderId2 = orderId++;
    // take order
    await market.connect(user).takeOrder(orderId1, 1, {value: maxPrice.div(100)});
    await market.takeOrder(orderId2, 1);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
