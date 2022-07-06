// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

// https://github.com/rugpullindex/ERC4973/blob/master/src/interfaces/IERC721Metadata.sol
interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
