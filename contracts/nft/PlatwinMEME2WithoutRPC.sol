// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/// @dev MEME is Platwin NFT example, maybe some emoji, some cop?
/// @dev use IPFS to store NFT resource, so we specify uri when user mint nft
contract PlatwinMEME2WithoutRPC is ERC721, Ownable {

    uint public tokenIndex;

    bool public mintPaused;

    mapping(uint => string) private tokenUri;

    mapping(uint => address) public minter;

    /* event */
    event MintPaused(bool paused);
    event BaseURIUpdated(string oldURI, string newURI);

    constructor()ERC721("Platwin MEME(without RPC)", "PLATWIN-MEME") Ownable(){
    }

    function pauseMint(bool paused) public onlyOwner {
        mintPaused = paused;
        emit MintPaused(paused);
    }

    /// @notice everyone could mint Platwin MEME
    /// @notice we use a simple auto-increment tokenId
    function mint(address to, string memory uri) public {
        require(!mintPaused, 'mint paused');
        _mint(to, tokenIndex);
        tokenUri[tokenIndex] = uri;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }

    function safeMint(address to, string memory uri) public {
        require(!mintPaused, 'mint paused');
        _safeMint(to, tokenIndex);
        tokenUri[tokenIndex] = uri;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }
    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked('ipfs://', tokenUri[tokenId]));
    }
}
