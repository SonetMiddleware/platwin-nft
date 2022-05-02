// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

contract DAORegistry is OwnableUpgradeable {

    mapping(IERC721 => bool) public whitelist;
    mapping(IERC721 => bool) public daoList;

    event UpdateWhiteList(IERC721 nft, bool enabled);
    event CreateDAO(IERC721 indexed nft, string name, string facebook, string twitter);

    function initialize() public initializer {
        __Ownable_init();
    }

    function setWhiteList(IERC721 nft, bool enabled) public onlyOwner {
        whitelist[nft] = enabled;
        emit UpdateWhiteList(nft, enabled);
    }

    function createDao(IERC721 nft, string memory name, string memory facebook, string memory twitter) public {
        require(whitelist[nft], 'illegal');
        require(!daoList[nft], 'already existed');
        require(nft.balanceOf(msg.sender) > 0, 'at least 1 token is required');
        daoList[nft] = true;
        emit CreateDAO(nft, name, facebook, twitter);
    }
}
