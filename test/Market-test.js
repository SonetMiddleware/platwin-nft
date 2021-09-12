const {expect} = require("chai");

const emptyAddr = ethers.utils.getAddress("0x0000000000000000000000000000000000000000");
describe('Platwin NFT Market', function () {
    let testERC20;
    let router;
    let meme2WithoutRPC;
    let owner;
    let user;
    let baseURI = "http://api.platwin.io/v1/meme/";
    let marketLogic;
    let marketState;
    let market, feeRate;
    let tokenId;
    let multiplier = ethers.BigNumber.from('1000000000000000000');
    beforeEach('initialize', async function () {
        const DealRouter = await ethers.getContractFactory("DealRouter");
        router = await DealRouter.deploy();
        const PlatwinMEME2WithoutRPC = await ethers.getContractFactory("PlatwinMEME2WithoutRPC");
        meme2WithoutRPC = await PlatwinMEME2WithoutRPC.deploy();
        [owner, user] = await ethers.getSigners();
        expect(await meme2WithoutRPC.owner()).to.equal(owner.address);

        /* deploy market */
        const Market = await ethers.getContractFactory("Market");
        marketLogic = await Market.deploy();
        const MarketProxy = await ethers.getContractFactory("MarketProxy");
        marketState = await MarketProxy.deploy(marketLogic.address, Buffer.from(''), router.address);
        market = await Market.attach(marketState.address);

        // support NFT
        await market.setSupportedNFT(meme2WithoutRPC.address, true);
        expect(await market.supportedNFT(meme2WithoutRPC.address)).to.equal(true);
        // mint nft first
        tokenId = await meme2WithoutRPC.tokenIndex();
        await meme2WithoutRPC.connect(user).mint(user.address, baseURI);
        await meme2WithoutRPC.connect(user).approve(market.address, tokenId);
        /* set router */
        // 1%
        feeRate = multiplier.div(100);
        await router.setFixedRateFee(market.address, feeRate);

        /* testERC20 */
        const TestERC20 = await ethers.getContractFactory("TestERC20");
        testERC20 = await TestERC20.deploy();
        let amount = multiplier.mul(1000);
        await testERC20.transfer(user.address, amount);
        await testERC20.approve(router.address, amount.mul(100));
        await testERC20.connect(user).approve(router.address, amount.mul(100));
    });
    it('ERC721 one price order', async function () {
        /* make order */
        let minPrice = ethers.BigNumber.from('100000000000000000000');
        let maxPrice = minPrice;
        let startBlock = ethers.BigNumber.from(await network.provider.send('eth_blockNumber')).add(1);
        let duration = 10;
        await market.connect(user).makeOrder(true, meme2WithoutRPC.address, tokenId, 1, testERC20.address, minPrice,
            maxPrice, startBlock, duration);
        let orderId = await market.ordersNum();
        let order = await market.orders(orderId);
        expect(order.status).to.equal(0);
        expect(order.tokenId).to.equal(tokenId);
        expect(order.nft).to.equal(meme2WithoutRPC.address);
        expect(order.is721).to.equal(true);
        expect(order.seller).to.equal(user.address);
        expect(order.sellToken).to.equal(testERC20.address);
        expect(order.initAmount).to.equal(1);
        expect(order.minPrice).to.equal(minPrice);
        expect(order.maxPrice).to.equal(maxPrice);
        expect(order.startBlock).to.equal(startBlock);
        expect(order.duration).to.equal(duration);
        expect(order.amount).to.equal(1);
        expect(order.finalPrice).to.equal(0);
        let buyers = await market.orderBuyers(orderId);
        expect(buyers.length).to.equal(0);
        expect(await meme2WithoutRPC.ownerOf(order.tokenId)).to.equal(market.address);

        /* take order */
        let amountOut = order.amount;
        let buyerBalanceBefore = await testERC20.balanceOf(owner.address);
        let sellerBalanceBefore = await testERC20.balanceOf(user.address);
        let feeBalanceBefore = await testERC20.balanceOf(router.address);
        await market.takeOrder(orderId, amountOut);
        let buyerBalanceAfter = await testERC20.balanceOf(owner.address);
        let sellerBalanceAfter = await testERC20.balanceOf(user.address);
        let feeBalanceAfter = await testERC20.balanceOf(router.address);
        // check order status
        order = await market.orders(orderId);
        expect(order.status).to.equal(2);
        expect(order.finalPrice).to.equal(order.minPrice);
        buyers = await market.orderBuyers(orderId);
        expect(buyers.length).to.equal(1);
        expect(buyers[0]).to.equal(owner.address);

        // check asset
        expect(await meme2WithoutRPC.ownerOf(order.tokenId)).to.equal(owner.address);
        let buyerBalanceChange = buyerBalanceBefore.sub(buyerBalanceAfter);
        let sellerBalanceChange = sellerBalanceAfter.sub(sellerBalanceBefore);
        let feeBalanceChange = feeBalanceAfter.sub(feeBalanceBefore);
        let volume = order.finalPrice;
        let fee = volume.mul(feeRate).div(multiplier);
        expect(feeBalanceChange).to.equal(fee);
        expect(buyerBalanceChange).to.equal(volume);
        expect(sellerBalanceChange).to.equal(volume.sub(fee));
    });
    it('ERC721 Dutch auction(sell token is ETH)', async function () {
        /* make order */
        let minPrice = ethers.BigNumber.from('100000000000000000000');
        let maxPrice = minPrice.mul(2);
        let startBlock = ethers.BigNumber.from(await network.provider.send('eth_blockNumber')).add(1);
        let duration = 10;
        await market.connect(user).makeOrder(true, meme2WithoutRPC.address, tokenId, 1, emptyAddr, minPrice, maxPrice,
            startBlock, duration);
        let orderId = await market.ordersNum();
        let order = await market.orders(orderId);
        expect(await market.getPrice(orderId)).to.equal(order.maxPrice);

        /* fast forward 5 block */
        while (true) {
            let height = ethers.BigNumber.from(await network.provider.send('eth_blockNumber'));
            if (height.gte(startBlock.add(5))) {
                break;
            }
            await network.provider.send('evm_mine');
        }
        // check price
        let height = ethers.BigNumber.from(await network.provider.send('eth_blockNumber'));
        let priceCalculated = order.maxPrice.sub(order.maxPrice.sub(order.minPrice).mul(height.sub(order.startBlock))
            .div(order.duration));
        expect(await market.getPrice(orderId)).to.equal(priceCalculated);
        // snapshot
        let snapshot = await network.provider.send('evm_snapshot');
        /* take order */
        let priceExecuted = order.maxPrice.sub(order.maxPrice.sub(order.minPrice).mul(height.add(1).sub(order.startBlock))
            .div(order.duration));
        let amountOut = order.amount;
        let provider = await ethers.provider;
        let buyerBalanceBefore = await provider.getBalance(owner.address);
        let sellerBalanceBefore = await provider.getBalance(user.address);
        let feeBalanceBefore = await provider.getBalance(router.address);
        let tx = await market.takeOrder(orderId, amountOut, {value: priceExecuted});
        let txReceipt = await tx.wait();
        let buyerBalanceAfter = await provider.getBalance(owner.address);
        let sellerBalanceAfter = await provider.getBalance(user.address);
        let feeBalanceAfter = await provider.getBalance(router.address);
        // check order status
        order = await market.orders(orderId);
        expect(order.status).to.equal(2);
        expect(order.finalPrice).to.equal(priceExecuted);
        let buyers = await market.orderBuyers(orderId);
        expect(buyers.length).to.equal(1);
        expect(buyers[0]).to.equal(owner.address);

        // check asset
        expect(await meme2WithoutRPC.ownerOf(order.tokenId)).to.equal(owner.address);
        let buyerBalanceChange = buyerBalanceBefore.sub(buyerBalanceAfter);
        let sellerBalanceChange = sellerBalanceAfter.sub(sellerBalanceBefore);
        let feeBalanceChange = feeBalanceAfter.sub(feeBalanceBefore);
        let volume = priceExecuted;
        let fee = volume.mul(feeRate).div(multiplier);
        expect(feeBalanceChange).to.equal(fee);
        expect(sellerBalanceChange).to.equal(volume.sub(fee));
        expect(buyerBalanceChange).to.equal(volume.add(tx.gasPrice.mul(txReceipt.gasUsed)));

        /* revert take order and fast forward enough block */
        await network.provider.send('evm_revert', [snapshot]);
        while (true) {
            let height = ethers.BigNumber.from(await network.provider.send('eth_blockNumber'));
            if (height.gte(startBlock.add(duration))) {
                break;
            }
            await network.provider.send('evm_mine');
        }
        expect(await market.getPrice(orderId)).to.equal(order.minPrice);
        await expect(market.takeOrder(orderId, amountOut)).revertedWith('not enough');
        // check order status
        order = await market.orders(orderId);
        expect(order.status).to.equal(0);
        expect(order.finalPrice).to.equal(0);
    });
    it('cancel ERC721 order', async function () {
        /* make order */
        let minPrice = ethers.BigNumber.from('100000000000000000000');
        let maxPrice = minPrice.mul(2);
        let startBlock = ethers.BigNumber.from(await network.provider.send('eth_blockNumber')).add(1);
        let duration = 10;
        await market.connect(user).makeOrder(true, meme2WithoutRPC.address, tokenId, 1, testERC20.address,
            minPrice, maxPrice, startBlock, duration);
        let orderId = await market.ordersNum();
        let order = await market.orders(orderId);
        expect(await meme2WithoutRPC.ownerOf(order.tokenId)).to.equal(market.address);
        // snapshot
        let snapshot = await network.provider.send('evm_snapshot');
        // cancel order
        await market.connect(user).cancelOrder(orderId);
        expect(await meme2WithoutRPC.ownerOf(order.tokenId)).to.equal(user.address);
        order = await market.orders(orderId);
        expect(order.status).to.equal(4);
        expect(order.amount).to.equal(0);
        expect(order.finalPrice).to.equal(0);
        await expect(market.getPrice(orderId)).to.be.revertedWith("canceled order");

        // revert
        await network.provider.send('evm_revert', [snapshot]);
        // take order
        order = await market.orders(orderId);
        await market.takeOrder(orderId, order.amount);
        order = await market.orders(orderId);
        expect(order.status).to.equal(2);
        // cannot cancel SOLD order
        await expect(market.connect(user).cancelOrder(orderId)).to.be.revertedWith('illegal order status');
    });
});
