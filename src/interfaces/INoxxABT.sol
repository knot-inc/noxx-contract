// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface INoxxABT {
  /// @dev Mint token to a specific address. Token can be minted only once per address.
  /// @param to The address that will receive the minted tokens.
  /// @param tokenURI the tokenURI
  function mint(address to, string memory tokenURI) external;

  /// @dev Update tokenURI
  /// @param tokenId Id that requires update.
  /// @param tokenURI the new tokenURI
  function updateTokenURI(uint256 tokenId, string memory tokenURI) external;

  /// @dev Return tokenId from owner address
  /// @param owner owner address
  function tokenByOwner(address owner) external view returns (uint256);

  /// @dev Return tokenURI from owner address
  /// @param owner owner address
  function tokenURIByOwner(address owner) external view returns (string memory);
}
