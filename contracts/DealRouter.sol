// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IResPublicaAsset.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

//////////////////////
// 1. collect fee from NFT market, and NFT minting
// 2. fee is supported ERC20 token
// 3. administer fee rate of all actions
// 4. use router to charge, users could approve feeToken only once for all actions
//////////////////////

interface DealRouterInterface {

    // return the amount of fee collected and `to` received
    function dealWithFixedRateFee(IERC20 feeToken, address payable payer, address payable recipient, uint volume)
    external payable returns (uint, uint);
}

contract DealRouter is DealRouterInterface, Ownable {
    using SafeERC20 for IERC20;

    struct FeeCfg {
        uint rate;
        bool initialized;
    }
    /// @dev fee rate is fixed, such as NFT trading
    /// @dev contract => fee config with fixed rate
    mapping(address => FeeCfg) public fixedRateFee;

    mapping(IERC20 => bool) public feeTokenWhitelist;

    /* event */
    event FixedRateFeeUpdated(address market, uint feeRate);
    event SetFeeToken(IERC20 feeToken, bool value);
    event FeeCollected(address application, address payer, IERC20 feeToken, uint amount);
    event WithdrawFee(IERC20 feeToken, address feeTo, uint amount);

    constructor(){
        // enable ETH
        feeTokenWhitelist[IERC20(address(0))] = true;
    }

    /* admin functions */

    function setFixedRateFee(address app, uint feeRate) public onlyOwner {
        require(app != address(0), 'illegal application contract');
        fixedRateFee[app].rate = feeRate;
        fixedRateFee[app].initialized = true;
        emit FixedRateFeeUpdated(app, feeRate);
    }

    function setFeeToken(IERC20 feeToken, bool value) public onlyOwner {
        feeTokenWhitelist[feeToken] = value;
        emit SetFeeToken(feeToken, value);
    }

    function dealWithFixedRateFee(IERC20 feeToken, address payable payer, address payable recipient, uint volume)
    public payable override returns (uint feeCollected, uint recipientReceived){
        FeeCfg storage cfg = fixedRateFee[msg.sender];
        require(cfg.initialized, 'msg.sender has not permission');
        feeCollected = volume * cfg.rate / 1e18;
        recipientReceived = volume - feeCollected;
        if (address(feeToken) == address(0)) {
            uint etherAmount = msg.value;
            require(etherAmount >= volume, 'not enough');
            // refund
            if (etherAmount > volume) {
                payer.transfer(etherAmount - volume);
            }
            // send ether
            if (recipientReceived > 0) {
                recipient.transfer(recipientReceived);
            }
        } else {
            if (recipientReceived > 0) {
                feeToken.safeTransferFrom(payer, recipient, recipientReceived);
            }
            if (feeCollected > 0) {
                feeToken.safeTransferFrom(payer, address(this), feeCollected);
            }
        }
        emit FeeCollected(msg.sender, payer, feeToken, feeCollected);
    }

    function withdrawFee(IERC20 feeToken, address payable feeTo) public onlyOwner {
        uint balance = 0;
        address self = address(this);
        if (address(feeToken) == address(0)) {
            balance = self.balance;
            feeTo.transfer(balance);
        } else {
            balance = feeToken.balanceOf(self);
            feeToken.safeTransfer(feeTo, balance);
        }
        emit WithdrawFee(feeToken, feeTo, balance);
    }
}
