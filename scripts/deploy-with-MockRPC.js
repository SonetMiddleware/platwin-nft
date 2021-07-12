async function main() {
    const MockRPC = await ethers.getContractFactory("MockRPC");
    let rpc = await MockRPC.deploy();
    console.log('rpc deploy tx send, pending addr', rpc.address);
    const RPCRouter = await ethers.getContractFactory("RPCRouter");
    let router = await RPCRouter.deploy(rpc.address);
    console.log('RPCRouter deploy tx send, pending addr', router.address);
    const PlatwinMEME = await ethers.getContractFactory("PlatwinMEME");
    let meme = await PlatwinMEME.deploy(router.address, "http://api.platwin.io/v1/meme/");
    console.log('MEME deploy tx send, pending addr', meme.address);
    const PlatwinMEME2 = await ethers.getContractFactory("PlatwinMEME2");
    let meme2 = await PlatwinMEME2.deploy(router.address);
    console.log('MEME2 deploy tx send, pending addr', meme2.address);
    const PlatwinBatchMeme = await ethers.getContractFactory("PlatwinBatchMEME");
    let batchMeme = await PlatwinBatchMeme.deploy();
    console.log('BatchMEME deploy tx send, pending addr', batchMeme.address);

    /* deploy market */
    const Market = await ethers.getContractFactory("Market");
    let marketLogic = await Market.deploy();
    console.log('Market deploy tx send, pending addr', marketLogic.address);
    const MarketProxy = await ethers.getContractFactory("MarketProxy");
    // we should specify gasLimit, because marketLogic has not deployed
    let marketState = await MarketProxy.deploy(marketLogic.address, Buffer.from(''), router.address, rpc.address,
        {gasLimit: 1125055});
    console.log('MarketProxy deploy tx send, pending addr', marketState.address);

    let deployments = {
        MockRPC: rpc.address,
        RPCRouter: router.address,
        PlatwinMEME: meme.address,
        PlatwinMEME2: meme2.address,
        PlatwinBatchMeme: batchMeme.address,
        Market: marketLogic.address,
        MarketProxy: marketState.address,
    };
    console.log('deploy successfully', deployments);
    console.log('waiting all tx completed...');
    await rpc.deployed();
    console.log('rpc deployed');
    await router.deployed();
    console.log('router deployed');
    await meme.deployed();
    console.log('meme deployed');
    await meme2.deployed();
    console.log('meme2 deployed');
    await batchMeme.deployed();
    console.log('batchMeme deployed');
    await marketLogic.deployed();
    console.log('marketLogic deployed');
    await marketState.deployed();
    console.log('marketState deployed');
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
