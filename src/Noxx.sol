// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import './interfaces/INoxx.sol';
import './interfaces/INoxxABT.sol';
import './interfaces/IVerifier.sol';

/// @title Contract that manages proof verification/minting
/// @author Tomo
/// @dev does proof verification and mint in the separate process.
contract Noxx is INoxx {
  IVerifier verifier;
  INoxxABT noxxABT;

  /// mapping for checking verifications
  mapping(address => bool) private verifiedAccounts;

  constructor(IVerifier _verifier, INoxxABT _noxxABT) {
    verifier = _verifier;
    noxxABT = _noxxABT;
  }

  /// @dev Verify zk proof, if valid then add to the allowed list
  function executeProofVerification(
    uint256[8] calldata proof,
    uint256[1] calldata input,
    address from
  ) external returns (bool) {
    bool isValid = verifier.verifyProof(
      [proof[0], proof[1]],
      [[proof[2], proof[3]], [proof[4], proof[5]]],
      [proof[6], proof[7]],
      input
    );
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
