// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFTCollection is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable
{
    uint256 private _nextTokenId;
    uint256 public constant MAX_SUPPLY = 1000;

    constructor(
        address initialOwner
    ) ERC721("MyNFTCollection", "MNFT") Ownable(initialOwner) {}

    function safeMint(address to, string memory uri) public onlyOwner {
        require(totalSupply() < MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

//0xf5eF066dd8c24B47eEF57754b457bd32C03fa086  contract address
//0xAF290Ba635d300590bf1760CE17357212b2C69e1  initial owner
//0xa3AB0Ab143C69c1a2b61d088F5d398fDA681df44  to

//bafkreidf33nk3msi4ttjrcqlisvgkkeagvma74ledg6qejbehsfc64rflq  json
//bafkreibh3bak2b53usjcfvdf7z7xlwak7fc3sfz3pus5gw7kd3zdpobpm4  jpg

//ipfs://bafkreidf33nk3msi4ttjrcqlisvgkkeagvma74ledg6qejbehsfc64rflq  json
//ipfs://bafkreibh3bak2b53usjcfvdf7z7xlwak7fc3sfz3pus5gw7kd3zdpobpm4  jpg
