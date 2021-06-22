// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IFeeCollector} from '../FeeCollector.sol';
import '../Math.sol';

contract Market is IERC721Receiver, IERC1155Receiver, Ownable {

    using SafeERC20 for IERC20;

    IFeeCollector public feeCollector;
    IERC20 public RPC;

    enum OrderStatus{INIT, PARTIAL_SOLD, SOLD, PARTIAL_SOLD_CANCELED, CANCELED}

    struct Order {
        OrderStatus status;
        uint tokenId;
        address nft; // ERC721 or ERC1155
        bool is721;

        address seller;
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

    /* event */
    event SetSupportedNFT(address nft, bool supported);
    event MakeOrder(uint orderId, address seller, address nft, uint tokenId, uint amount);
    event TakeOrder(uint orderId, address buyer, address nft, uint tokenId, uint amount, uint rpcAmount);
    event CancelOrder(uint orderId, address nft, uint tokenId, uint remains);

    constructor(IFeeCollector collector, IERC20 rpc)Ownable(){
        feeCollector = collector;
        RPC = rpc;
    }

    function setSupportedNFT(address nft, bool supported) public onlyOwner {
        supportedNFT[nft] = supported;
        emit SetSupportedNFT(nft, supported);
    }

    /// return order id
    function makeOrder(bool is721, address nft, uint tokenId, uint tokenAmount, uint minPrice, uint maxPrice,
        uint startBlock, uint duration)
    public returns (uint){
        // check nft supported
        require(supportedNFT[nft], 'unsupported NFT');
        // check order condition
        require(maxPrice >= minPrice, 'illegal price');
        require(startBlock >= block.number, 'illegal start block');
        // transfer asset in
        if (is721) {
            IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);
            require(tokenAmount == 1, 'illegal token amount');
        } else {
            IERC1155(nft).safeTransferFrom(msg.sender, address(this), tokenId, tokenAmount, "");
        }
        // record order
        ordersNum++;
        orders[ordersNum] = Order(OrderStatus.INIT, tokenId, nft, is721, msg.sender, tokenAmount, tokenAmount,
            minPrice, maxPrice, 0, startBlock, duration, new address[](0));
        emit MakeOrder(ordersNum, msg.sender, nft, tokenId, tokenAmount);
        return ordersNum;
    }

    function takeOrder(uint orderId, uint amountOut) public returns (bool){
        Order storage order = orders[orderId];
        // check order
        require(amountOut <= order.amount, 'insufficient amountOut');
        require(order.status == OrderStatus.INIT || order.status == OrderStatus.PARTIAL_SOLD, 'illegal order status');
        // transfer asset in
        uint price = getPrice(orderId);
        uint rpcAmount = price * amountOut;
        uint feeAmount = feeCollector.fixedRateCollect(msg.sender, rpcAmount);
        // if fee > rpcAmount, revert
        RPC.safeTransferFrom(msg.sender, address(this), rpcAmount - feeAmount);
        // transfer nft out
        if (order.is721) {
            IERC721(order.nft).safeTransferFrom(address(this), msg.sender, order.tokenId);
        } else {
            IERC1155(order.nft).safeTransferFrom(address(this), msg.sender, order.tokenId, amountOut, "");
        }
        // update order status
        order.amount -= amountOut;
        if (order.amount == 0) {
            order.status = OrderStatus.SOLD;
            order.finalPrice = price;
        } else {
            order.status = OrderStatus.PARTIAL_SOLD;
        }
        order.buyers.push(msg.sender);
        emit TakeOrder(orderId, msg.sender, order.nft, order.tokenId, amountOut, rpcAmount);
        return true;
    }

    function cancelOrder(uint orderId) public returns (bool) {
        Order storage order = orders[orderId];
        // check order
        require(msg.sender == order.seller);
        require(order.status == OrderStatus.INIT || order.status == OrderStatus.PARTIAL_SOLD, 'illegal order status');
        // transfer asset out
        if (order.is721) {
            IERC721(order.nft).safeTransferFrom(address(this), msg.sender, order.tokenId);
        } else {
            IERC1155(order.nft).safeTransferFrom(address(this), msg.sender, order.tokenId, order.amount, "");
        }
        // update order
        order.amount = 0;
        if (order.status == OrderStatus.INIT) {
            order.status = OrderStatus.CANCELED;
        } else {
            order.status = OrderStatus.PARTIAL_SOLD_CANCELED;
        }
        emit CancelOrder(orderId, order.nft, order.tokenId, order.amount);
        return true;
    }

    function getPrice(uint orderId) public view returns (uint){
        Order storage order = orders[orderId];
        require(order.status != OrderStatus.PARTIAL_SOLD_CANCELED
            && order.status != OrderStatus.CANCELED, 'canceled order');
        if (order.status == OrderStatus.SOLD) {
            return order.finalPrice;
        } else {
            if (block.number > order.startBlock + order.duration) {
                return order.minPrice;
            } else if (block.number < order.startBlock) {
                return order.maxPrice;
            } else {
                return order.maxPrice - (order.maxPrice - order.minPrice) * (block.number - order.startBlock) / order.duration;
            }
        }
    }

    // ERC165
    function supportsInterface(bytes4 interfaceId) public pure override returns (bool){
        return interfaceId == 0x150b7a02 || interfaceId == 0x4e2312e0;
    }

    function onERC721Received(address operator, address, uint256, bytes calldata)
    public view override returns (bytes4){
        if (address(this) != operator) {
            return 0;
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    function onERC1155Received(address operator, address, uint256, uint256, bytes calldata)
    public view override returns (bytes4){
        if (address(this) != operator) {
            return 0;
        }
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address operator, address, uint256[] calldata, uint256[] calldata,
        bytes calldata) public view override returns (bytes4){
        if (address(this) != operator) {
            return 0;
        }
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }
}