// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import {IFeeCollector} from '../FeeCollector.sol';

/// @dev MEME is Platwin NFT example, maybe some emoji, some cop?
contract PlatwinMEME is ERC721, Ownable {

    IFeeCollector public feeCollector;

    uint public tokenIndex;
    string public baseURI;

    /* event */
    event BaseURIUpdated(string oldURI, string newURI);

    constructor(IFeeCollector collector, string memory uri)ERC721("Platwin MEME", "PLATWIN-MEME") Ownable(){
        feeCollector = collector;
        baseURI = uri;
    }

    /// @notice everyone could mint Platwin MEME
    /// @notice we use a simple auto-increment tokenId
    function mint(address to) public {
        feeCollector.fixedAmountCollect(msg.sender);
        _mint(to, tokenIndex);
        tokenIndex++;
    }

    function safeMint(address to) public {
        feeCollector.fixedAmountCollect(msg.sender);
        _safeMint(to, tokenIndex);
        tokenIndex++;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        string memory oldURI = baseURI;
        baseURI = newBaseURI;
        emit BaseURIUpdated(oldURI, newBaseURI);
    }

    function _baseURI() internal override view returns (string memory){
        return baseURI;
    }
}
