// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

contract DAORegistry is OwnableUpgradeable {

    mapping(string => bool) public collectionDaoList;

    event CreateDAO(string collectionSlug, string name, string facebook, string twitter);

    function initialize() public initializer {
        __Ownable_init();
    }

    function createDao(string memory collectionSlug, string memory name, string memory facebook, string memory twitter) public {
        require(!collectionDaoList[collectionSlug], 'already existed');
        collectionDaoList[collectionSlug] = true;
        emit CreateDAO(collectionSlug, name, facebook, twitter);
    }
}
