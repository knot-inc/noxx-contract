//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

/// @title Verifier interface.
/// @dev Interface of Verifier contract.
interface IUltraVerifier {
  // @dev Verifies a proof with UltraVerifier
  function verify(
    bytes memory proof,
    bytes32[] memory publicInputs
  ) external view returns (bool);
}
