require("@nomiclabs/hardhat-waffle");
const env = require('./.env.json');

INFURO_API_KEY = env.INFURO;
PRIV = env.PRIVATE_KEY;
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.8.4",
    settings: {
        optimizer: {
            enabled: true,
            runs: 1000
        }
    },
    networks: {
        ropsten: {
            url: `https://ropsten.infura.io/v3/${INFURO_API_KEY}`,
            accounts: [`0x${PRIV}`]
        }
    }
};
