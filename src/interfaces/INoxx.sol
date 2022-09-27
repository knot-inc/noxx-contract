// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface INoxx {
  /// @dev Verify zk proof, if valid then add to the allowed list
  function executeProofVerification(
    uint256[8] calldata proof,
    uint256[4] calldata input,
    address from
  ) external returns (bool);

  /// @dev mintNFT if user is in the allowed list
  function mintNFT(address to, string memory _tokenURI) external;
}
