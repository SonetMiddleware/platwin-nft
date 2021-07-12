require("@nomiclabs/hardhat-waffle");
const env = require('./.env.json');

INFURO_API_KEY = env.INFURO;
PRIV = env.PRIVATE_KEY;
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: {
        version: '0.8.4',
        settings: {
            optimizer: {
                enabled: true,
                runs: 999999
            }
        }
    },
    networks: {
        ropsten: {
            url: `https://ropsten.infura.io/v3/${INFURO_API_KEY}`,
            accounts: [`0x${PRIV}`]
        },
        kovan: {
            url: `https://kovan.infura.io/v3/${INFURO_API_KEY}`,
            accounts: [`0x${PRIV}`]
        },
        bsc_testnet: {
            url: `https://data-seed-prebsc-1-s3.binance.org:8545/`,
            accounts: [`0x${PRIV}`]
        }
    }
};
