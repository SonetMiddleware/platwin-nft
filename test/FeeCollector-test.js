const {expect} = require("chai");

/// @notice we test fee collecting at other test case
describe("Fee Collector", function () {
    let rpc;
    let collector;
    let feeTo;
    let owner;
    beforeEach('deploy contract', async function () {
        const MockRPC = await ethers.getContractFactory("MockRPC");
        rpc = await MockRPC.deploy();
        const FeeCollector = await ethers.getContractFactory("FeeCollector");
        collector = await FeeCollector.deploy(rpc.address);
        [owner, feeTo] = await ethers.getSigners();
        expect(await collector.owner()).to.equal(owner.address);
    });
    it('configure', async function () {
        // use any address as nft and market contract address
        let [_, nft, market] = await ethers.getSigners();
        let fixedAmount = ethers.BigNumber.from('1000000000000000000'); // 1e18
        let fixedRate = ethers.BigNumber.from('10000000000000000'); // 1e16
        await collector.setFixedAmountFee(nft.getAddress(), fixedAmount);
        await collector.setFixedRateFee(market.getAddress(), fixedRate); // 1%

        expect(await collector.fixedAmountFee(nft.getAddress())).to.equal(fixedAmount);
        expect(await collector.fixedRateFee(market.getAddress())).to.equal(fixedRate);
    });
    it('withdraw & burn fee', async function () {
        let amount = ethers.BigNumber.from('100000000000000000000'); // 100
        rpc.transfer(collector.address, amount);
        expect(await rpc.balanceOf(collector.address)).to.equal(amount);

        amount = amount.div(2);
        await collector.burnFee(amount);
        expect(await rpc.balanceOf(collector.address)).to.equal(amount);

        await collector.withdrawFee(feeTo.address);
        expect(await rpc.balanceOf(collector.address)).to.equal(0);
        expect(await rpc.balanceOf(feeTo.address)).to.equal(amount);
    });
});