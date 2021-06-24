async function main() {
    const MockRPC = await ethers.getContractFactory("MockRPC");
    let rpc = await MockRPC.deploy();
    const FeeCollector = await ethers.getContractFactory("FeeCollector");
    let collector = await FeeCollector.deploy(rpc.address);
    const PlatwinMEME = await ethers.getContractFactory("PlatwinMEME");
    let meme = await PlatwinMEME.deploy(collector.address, "http://api.platwin.io/v1/meme/");
    const PlatwinBatchMeme = await ethers.getContractFactory("PlatwinBatchMEME");
    let batchMeme = await PlatwinBatchMeme.deploy();

    /* deploy market */
    const Market = await ethers.getContractFactory("Market");
    let marketLogic = await Market.deploy();
    const MarketProxy = await ethers.getContractFactory("MarketProxy");
    let marketState = await MarketProxy.deploy(marketLogic.address, Buffer.from(''), collector.address, rpc.address);

    let deployments = {
        MockRPC: rpc.address,
        FeeCollector: collector.address,
        PlatwinMEME: meme.address,
        PlatwinBatchMeme: batchMeme.address,
        Market: marketLogic.address,
        MarketProxy: marketState.address,
    };
    console.log('deploy successfully', deployments);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });