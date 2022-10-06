// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/introspection/ERC165.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './interfaces/IERC721Metadata.sol';
import './interfaces/IERC4973.sol';

/// @notice Reference implementation of EIP-4973 tokens based on TimDaub (https://github.com/rugpullindex/ERC4973/blob/master/src/ERC4973.sol) but with ERC721 interface implemented so that it will be considered as NFT on etherscan
/// @author tomo.eth
abstract contract ERC4973 is ERC165, IERC721, IERC721Metadata, IERC4973 {
  error NonTransferrable();

  string private _name;
  string private _symbol;

  mapping(uint256 => address) private _owners;
  mapping(uint256 => string) private _tokenURIs;
  mapping(address => uint256) private _balances;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      interfaceId == type(IERC4973).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(_exists(tokenId), "tokenURI: token doesn't exist");
    return _tokenURIs[tokenId];
  }

  function burn(uint256 tokenId) public virtual override {
    require(msg.sender == ownerOf(tokenId), 'burn: sender must be owner');
    _burn(tokenId);
  }

  function balanceOf(address owner)
    public
    view
    virtual
    override(IERC4973, IERC721)
    returns (uint256)
  {
    require(
      owner != address(0),
      'balanceOf: address zero is not a valid owner'
    );
    return _balances[owner];
  }

  function ownerOf(uint256 tokenId)
    public
    view
    virtual
    override(IERC4973, IERC721)
    returns (address)
  {
    address owner = _owners[tokenId];
    require(owner != address(0), "ownerOf: token doesn't exist");
    return owner;
  }

  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return _owners[tokenId] != address(0);
  }

  function _mint(
    address to,
    uint256 tokenId,
    string memory uri
  ) internal virtual returns (uint256) {
    require(!_exists(tokenId), 'mint: tokenID exists');
    _balances[to] += 1;
    _owners[tokenId] = to;
    _tokenURIs[tokenId] = uri;
    emit Attest(to, tokenId);
    return tokenId;
  }

  function _burn(uint256 tokenId) internal virtual {
    address owner = ownerOf(tokenId);

    _balances[owner] -= 1;
    delete _owners[tokenId];
    delete _tokenURIs[tokenId];

    emit Revoke(owner, tokenId);
  }
}
