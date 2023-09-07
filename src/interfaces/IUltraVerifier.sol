//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

/// @title Verifier interface.
/// @dev Interface of Verifier contract.
interface IUltraVerifier {
  // @dev Verifies a proof with UltraVerifier
  function verify(
    bytes calldata _proof,
    bytes32[] calldata _publicInputs
  ) external view returns (bool);
}
