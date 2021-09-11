async function main() {
    const TestERC20 = await ethers.getContractFactory("TestERC20");
    let testERC20 = await TestERC20.deploy();
    console.log('testERC20 deploy tx send, pending addr', testERC20.address);
    await testERC20.deployed();
    console.log('testERC20 deployed');

    const DealRouter = await ethers.getContractFactory("DealRouter");
    let router = await DealRouter.deploy();
    console.log('DealRouter deploy tx send, pending addr', router.address);
    await router.deployed();
    console.log('router deployed');

    const PlatwinMEME2WithoutRPC = await ethers.getContractFactory("PlatwinMEME2WithoutRPC");
    let meme2WithoutRPC = await PlatwinMEME2WithoutRPC.deploy();
    console.log('PlatwinMEME2WithoutRPC deploy tx send, pending addr', meme2WithoutRPC.address);
    await meme2WithoutRPC.deployed();
    console.log('meme2WithoutRPC deployed');

    /* deploy market */
    const Market = await ethers.getContractFactory("Market");
    let marketLogic = await Market.deploy();
    console.log('Market deploy tx send, pending addr', marketLogic.address);
    await marketLogic.deployed();
    console.log('marketLogic deployed');

    const MarketProxy = await ethers.getContractFactory("MarketProxy");
    // we should specify gasLimit, because marketLogic has not deployed
    let marketState = await MarketProxy.deploy(marketLogic.address, Buffer.from(''), router.address);
    console.log('MarketProxy deploy tx send, pending addr', marketState.address);
    await marketState.deployed();
    console.log('marketState deployed');
    // 1% handling fee
    await router.setFixedRateFee(marketState.address, ethers.BigNumber.from('10000000000000000'));
    console.log('router config market fee');

    let market = await Market.attach(marketState.address);
    await market.setSupportedNFT('0xadDCa5C98b0fB6F8F9b4324D9f97F9Da55cbc3B2', true);
    await market.setSupportedNFT('0x917be393EeF337f280eF2000430F16c1340CAcAd', true);
    await market.setSupportedNFT('0x7c19f2eb9e4524D5Ef5114Eb646583bB0Bb6C8F8', true);
    await market.setSupportedNFT(meme2WithoutRPC.address, true);
    console.log('market supported MEME, MEME2, BatchMEME, PlatwinMEME2WithoutRPC');

    let deployments = {
            TestERC20: testERC20.address,
            DealRouter: router.address,
            MarketWithoutRPC: marketLogic.address,
            MarketProxyWithoutRPC: marketState.address,
            PlatwinMEME2WithoutRPC: meme2WithoutRPC.address,
        }
    ;
    console.log('deploy successfully', deployments);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
