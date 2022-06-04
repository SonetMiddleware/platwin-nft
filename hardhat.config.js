require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
const env = require('./.env.json');

INFURO_API_KEY = env.INFURO;
ALCHEMY_API_KEY = env.ALCHEMY;

PRIV_1 = env.PRIVATE_KEY_1;
PRIV_2 = env.PRIVATE_KEY_2;
PRIV_3 = env.PRIVATE_KEY_3;
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
        mainnet: {
            url: `https://mainnet.infura.io/v3/${INFURO_API_KEY}`,
            accounts: [`0x${PRIV_1}`],
            timeout: 10 * 60 * 1000
        },
        polygon: {
            url: 'https://polygon-rpc.com',
            accounts: [`0x${PRIV_1}`]
        },
        ropsten: {
            url: `https://ropsten.infura.io/v3/${INFURO_API_KEY}`,
            accounts: [`0x${PRIV_1}`]
        },
        kovan: {
            url: `https://kovan.infura.io/v3/${INFURO_API_KEY}`,
            accounts: [`0x${PRIV_1}`]
        },
        rinkeby: {
            url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
            accounts: [`0x${PRIV_1}`]
        },
        bsc_testnet: {
            url: `https://data-seed-prebsc-1-s3.binance.org:8545/`,
            accounts: [`0x${PRIV_1}`]
        },
        mumbai: {
            url: 'https://matic-mumbai.chainstacklabs.com',
            accounts: [`0x${PRIV_1}`, `0x${PRIV_2}`, `0x${PRIV_3}`],
        }
    }
};
