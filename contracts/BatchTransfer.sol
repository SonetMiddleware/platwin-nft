// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/**
* NFT Batch Airdrop Contract
* 1. mint NFT to this contract
* 2. invoke batchTransfer to airdrop
*/
contract BatchTransfer is Ownable, IERC721Receiver, IERC1155Receiver {
    function batchTransfer721(IERC721 token, address[] memory accounts, uint[]memory ids)
    public onlyOwner {
        require(ids.length == accounts.length, 'Invalid Args');
        address self = address(this);
        for (uint i = 0; i < ids.length; i++) {
            token.safeTransferFrom(self, accounts[i], ids[i]);
        }
    }

    /// @notice transfer different token to different account with different amounts
    function batchTransfer1155(IERC1155 token, address[] memory accounts, uint[]memory ids, uint[] memory amounts)
    public onlyOwner {
        require(ids.length == accounts.length && accounts.length == amounts.length, 'Invalid Args');
        address self = address(this);
        for (uint i = 0; i < accounts.length; i++) {
            token.safeTransferFrom(self, accounts[i], ids[i], amounts[i], '');
        }
    }

    /// @notice transfer same token to different account with different amounts
    function batchTransfer1155(IERC1155 token, address[] memory accounts, uint id, uint[] memory amounts)
    public onlyOwner {
        require(accounts.length == amounts.length, 'Invalid Args');
        address self = address(this);
        for (uint i = 0; i < accounts.length; i++) {
            token.safeTransferFrom(self, accounts[i], id, amounts[i], '');
        }
    }

    /// @notice transfer same token to different account with same amount
    function batchTransfer1155(IERC1155 token, address[] memory accounts, uint id, uint amount)
    public onlyOwner {
        address self = address(this);
        for (uint i = 0; i < accounts.length; i++) {
            token.safeTransferFrom(self, accounts[i], id, amount, '');
        }
    }

    /// @notice support IERC721Receiver and IERC1155Receiver
    function supportsInterface(bytes4 interfaceId) public pure override returns (bool){
        return interfaceId == 0x150b7a02 || interfaceId == 0x4e2312e0;
    }

    /// @notice only owner can transfer/mint nft to self
    function onERC721Received(address operator, address, uint256, bytes calldata)
    public view override returns (bytes4){
        if (owner() != operator) {
            return 0;
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice only owner can transfer/mint nft to self
    function onERC1155Received(address operator, address, uint256, uint256, bytes calldata)
    public view override returns (bytes4){
        if (owner() != operator) {
            return 0;
        }
        return IERC1155Receiver.onERC1155Received.selector;
    }

    /// @notice only owner can transfer/mint nft to self
    function onERC1155BatchReceived(address operator, address, uint256[] calldata, uint256[] calldata,
        bytes calldata) public view override returns (bytes4){
        if (owner() != operator) {
            return 0;
        }
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }
}
