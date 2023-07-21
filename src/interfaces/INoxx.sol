// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface INoxx {
  /// @dev Verify zk proof, if valid then add to the allowed list
  function executeProofVerification(
    bytes memory proof,
    bytes32[] memory publicInputs,
    address from
  ) external returns (bool);

  /// @dev mintNFT if user is in the allowed list
  function mintNFT(address to, string memory _tokenURI) external;
}
