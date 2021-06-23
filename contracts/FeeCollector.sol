// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';

//////////////////////
// 1. collect fee from NFT market, and NFT minting
// 2. fee is [RPC](Res Publica Cash)
// 3. administer fee rate of all actions
// 4. use collector to charge, users could approve RPC only once for all actions
//////////////////////

interface IFeeCollector {
    // return fee amount
    function fixedAmountCollect(address payer) external returns (uint);

    // return fee amount
    function fixedRateCollect(address payer, uint volume) external returns (uint);
}

contract FeeCollector is IFeeCollector, Ownable {

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
        fixedRateFee[nft] = rate;
        emit FixedRateFeeUpdated(nft, oldRate, rate);
    }

    function fixedAmountCollect(address payer) public override returns (uint) {
        uint amount = fixedAmountFee[msg.sender];
        if (amount > 0) {
            RPC.safeTransferFrom(payer, address(this), amount);
            emit FeeCollected(msg.sender, payer, amount);
        }
        return amount;
    }

    function fixedRateCollect(address payer, uint volume) public override returns (uint){
        uint rate = fixedRateFee[msg.sender];
        uint amount = rate * volume / 1e18;
        if (amount > 0) {
            RPC.safeTransferFrom(payer, address(this), amount);
            emit FeeCollected(msg.sender, payer, amount);
        }
        return amount;
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