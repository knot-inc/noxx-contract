// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import './interfaces/INoxx.sol';
import './interfaces/INoxxABT.sol';
import './interfaces/IUltraVerifier.sol';

/// @title Contract that manages proof verification/minting
/// @author Tomo
/// @dev does proof verification and mint in the separate process.
contract Noxx is INoxx {
  IUltraVerifier verifier;
  INoxxABT noxxABT;

  /// mapping for checking verifications
  mapping(address => bool) private verifiedAccounts;

  constructor(IUltraVerifier _verifier, INoxxABT _noxxABT) {
    verifier = _verifier;
    noxxABT = _noxxABT;
  }

  /// @dev Verify zk proof, if valid then add to the allowed list
  function executeProofVerification(
    bytes memory proof,
    bytes32[] memory publicInputs,
    address from
  ) external returns (bool) {
    // See IUltraVerifier for detail
    bool isValid = verifier.verify(proof, publicInputs);
    require(isValid, 'Proof Verification failed');
    verifiedAccounts[from] = true;
    return isValid;
  }

  /// @dev mintNFT if user is in the allowed list
  function mintNFT(address to, string memory _tokenURI) external {
    require(verifiedAccounts[to], 'Not verified to mint NFT');
    noxxABT.mint(to, _tokenURI);
  }

  function isVerifiedAccount(address account) public view returns (bool) {
    return verifiedAccounts[account];
  }
}
