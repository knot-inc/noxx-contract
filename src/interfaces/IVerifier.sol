//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

/// @title Verifier interface.
/// @dev Interface of Verifier contract.
interface IVerifier {
  function verifyProof(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    // Public input. in the order of commits[3](name, age, countrycode) and age
    uint256[4] memory input
  ) external view returns (bool);
}
