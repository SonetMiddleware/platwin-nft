// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract PlatwinMEMEWithMetaData is ERC721, Ownable {

    uint public tokenIndex;

    bool public mintPaused;

    mapping(uint => string) private imgUri;

    mapping(uint => address) public minter;

    /* event */
    event MintPaused(bool paused);
    event BaseURIUpdated(string oldURI, string newURI);

    constructor()ERC721("Platwin MEME With Metadata", "PLATWIN-MEME-2") Ownable(){
    }

    function pauseMint(bool paused) public onlyOwner {
        mintPaused = paused;
        emit MintPaused(paused);
    }

    /// @notice everyone could mint Platwin MEME
    /// @notice we use a simple auto-increment tokenId
    function mint(address to, string memory ipfsHash) public {
        require(!mintPaused, 'mint paused');
        _mint(to, tokenIndex);
        imgUri[tokenIndex] = ipfsHash;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }

    function safeMint(address to, string memory ipfsHash) public {
        require(!mintPaused, 'mint paused');
        _safeMint(to, tokenIndex);
        imgUri[tokenIndex] = ipfsHash;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }
    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory meta = '{"name":"Platwin MEME With Metadata","description":"Platwin MEME for Test","image":"https://ipfs.io/ipfs/';
        return string(abi.encodePacked(meta, imgUri[tokenId],'"}'));
    }
}
