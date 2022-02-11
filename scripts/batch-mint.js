async function main() {
    const BatchNFT = await ethers.getContractFactory('PlatwinBatchMEME');
    const batchNFT = await BatchNFT.attach('0x7c19f2eb9e4524D5Ef5114Eb646583bB0Bb6C8F8');
    const BatchTransfer = await ethers.getContractFactory('BatchTransfer');
    const batchTransfer = await BatchTransfer.attach('0x4ea062cef57791c2b3a53ff2122dc074fa431c60');
    const data = require('../airdrop-data/test.json');
    const emptyData = Buffer.from('');
    const mintTx = await batchNFT.mint(batchTransfer.address, data.id, data.addresses.length, emptyData);
    console.log('minting NFT...: %s', mintTx.hash);
    await mintTx.wait();
    console.log('NFT #%s minted', data.id);
    const airdropTx = await batchTransfer.functions[
        'batchTransfer1155(address,address[],uint256,uint256)'](batchNFT.address, data.addresses, data.id, 1);
    console.log('airdrop completed: %s', airdropTx.hash);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
