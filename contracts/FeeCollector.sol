// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import './Math.sol';

//////////////////////
// 1. collect fee from NFT market, and NFT minting
// 2. fee is [RPC](Res Publica Cash)
// 3. administer fee rate of all actions
// 4. use collector to charge, users could approve RPC only once for all actions
//////////////////////

interface IFeeCollector {
    function fixedAmountCollect(address payer) external;

    function fixedRateCollect(address payer, uint volume) external;
}

contract FeeCollector is IFeeCollector, Ownable, Math {

    using SafeERC20 for IERC20;

    /// @dev fee amount is fixed, such as NFT mint
    /// @dev contract => fee amount
    mapping(address => uint) public fixedAmountFee;
    /// @dev fee rate is fixed, such as NFT trading
    /// @dev contract => fee rate
    mapping(address => uint) public fixedRateFee;

    IERC20 public RPC;

    /* event */
    event FixedAmountFeeUpdated(address nft, uint oldAmount, uint amount);
    event FixedRateFeeUpdated(address market, uint oldRate, uint rate);
    event FeeCollected(address market, address payer, uint amount);
    event WithdrawFee(address feeTo, uint amount);
    event BurnFee(uint amount);

    constructor(IERC20 _RPC){
        RPC = _RPC;
    }

    /* admin functions */

    function setFixedAmountFee(address nft, uint amount) public onlyOwner {
        require(nft != address(0));
        uint oldAmount = fixedAmountFee[nft];
        fixedAmountFee[nft] = amount;
        emit FixedAmountFeeUpdated(nft, oldAmount, amount);
    }

    function setFixedRateFee(address nft, uint rate) public onlyOwner {
        require(nft != address(0));
        uint oldRate = fixedRateFee[nft];
        fixedAmountFee[nft] = rate;
        emit FixedRateFeeUpdated(nft, oldRate, rate);
    }

    function fixedAmountCollect(address payer) public override {
        uint amount = fixedAmountFee[msg.sender];
        if (amount > 0) {
            RPC.safeTransferFrom(payer, address(this), amount);
            emit FeeCollected(msg.sender, payer, amount);
        }
    }

    function fixedRateCollect(address payer, uint volume) public override {
        uint rate = fixedRateFee[msg.sender];
        uint amount = rate * volume / MULTIPLIER;
        if (amount > 0) {
            RPC.safeTransferFrom(payer, address(this), amount);
            emit FeeCollected(msg.sender, payer, amount);
        }
    }

    function withdrawFee(address feeTo) public onlyOwner {
        uint balance = RPC.balanceOf(address(this));
        RPC.safeTransfer(feeTo, balance);
        emit WithdrawFee(feeTo, balance);
    }

    function burnFee(uint amount) public onlyOwner {
        ERC20Burnable(address(RPC)).burn(amount);
        emit BurnFee(amount);
    }
}