//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

/// @title Verifier interface.
/// @dev Interface of Verifier contract.
interface IVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input // changes depending on public inputs
    ) external view returns (bool);
}
