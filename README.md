# marketplace-contracts

## Sell

- if first sell, Register Proxy;
- set NFT approve for all to Proxy;

Your NFT is always in your own hands until someone bought it.

## Buy

Based [Wyvern Exchange](https://wyvernprotocol.com/).

> note: Wyvern is out of date, we don't use it.

- transfer ETH from buyer to seller;
    - handling fee to marketplace;
- transfer NFT from seller to buyer;

## TODO List

- mint NFT/semi-NFT;
- marketplace(NFT trade);
    - one price;
    - Dutch auction;
    - With expiredTime;
- tax(burn RPC):
    - NFT mint tax;
    - NFT trade tax;