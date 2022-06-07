// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/// @dev MEME is Platwin NFT example, maybe some emoji, some cop?
/// @dev use IPFS to store NFT resource, so we specify uri when user mint nft
contract PlatwinNFT is ERC721, Ownable {

    uint public tokenIndex;

    mapping(uint => string) private tokenUri;

    mapping(uint => address) public minter;

    mapping(address => bool) public whitelist;

    string public baseURI;

    /* modifier */
    modifier inWhitelist(address who){
        require(whitelist[who], 'disabled');
        _;
    }

    /* events */
    event WhitelistUpdated(address who, bool enabled);
    event BaseURIUpdated(string oldURI, string newURI);

    constructor()ERC721("Platwin NFT", "PLATWIN-NFT") Ownable(){
        whitelist[msg.sender] = true;
        baseURI = "ipfs://";
    }

    function setWhitelist(address who, bool enabled) public onlyOwner {
        whitelist[who] = enabled;
        emit WhitelistUpdated(who, enabled);
    }

    function setBaseURI(string memory base) public onlyOwner {
        string memory old = baseURI;
        baseURI = base;
        emit BaseURIUpdated(old, base);
    }

    /// @notice everyone could mint Platwin MEME
    /// @notice we use a simple auto-increment tokenId
    function mint(address to, string memory uri) public inWhitelist(msg.sender) {
        _mint(to, tokenIndex);
        tokenUri[tokenIndex] = uri;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }

    function safeMint(address to, string memory uri) public inWhitelist(msg.sender) {
        _safeMint(to, tokenIndex);
        tokenUri[tokenIndex] = uri;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }

    function batchMint(address[] memory tos, string[] memory uris) public inWhitelist(msg.sender) {
        require(tos.length == uris.length, 'ill param');
        for (uint i = 0; i < uris.length; i++) {
            safeMint(tos[i], uris[i]);
        }
    }

    function batchMintToSameAddr(address to, string[] memory uris) public inWhitelist(msg.sender) {
        for (uint i = 0; i < uris.length; i++) {
            safeMint(to, uris[i]);
        }
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, tokenUri[tokenId]));
    }
}
