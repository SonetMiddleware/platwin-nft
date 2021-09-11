// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {DealRouterInterface} from '../DealRouter.sol';

contract MarketState is Ownable {
    DealRouterInterface public dealRouter;

    enum OrderStatus{INIT, PARTIAL_SOLD, SOLD, PARTIAL_SOLD_CANCELED, CANCELED}

    struct Order {
        OrderStatus status;
        uint tokenId;
        address nft; // ERC721 or ERC1155
        bool is721;

        address seller;
        IERC20 sellToken;
        uint initAmount;
        uint minPrice;
        uint maxPrice;
        uint startBlock;
        uint duration; // blocks

        uint amount; // remained amount
        uint finalPrice; // the price of order when NFT is sold, if there are no buyers, the final price is 0
        address[] buyers;
    }

    uint public ordersNum;
    mapping(uint => Order) public orders;

    mapping(address => bool) public supportedNFT;

    constructor(DealRouterInterface router)Ownable(){
        dealRouter = router;
    }
}
