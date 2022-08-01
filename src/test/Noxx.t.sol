// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import '../interfaces/INoxxABT.sol';
import '../interfaces/IVerifier.sol';
import '../Noxx.sol';

contract TestVerifier is IVerifier {
  function verifyProof(
    uint256[2] memory,
    uint256[2][2] memory,
    uint256[2] memory,
    uint256[1] memory input // changes depending on public inputs
  ) external pure returns (bool) {
    return (input[0] == 1);
  }
}

contract TestABT is INoxxABT {
  mapping(address => bool) private minted;

  function mint(address to, string memory) external {
    minted[to] = true;
  }

  function updateTokenURI(uint256 tokenId, string memory tokenURI) external {}

  function isMinted(address to) public view returns (bool) {
    return minted[to];
  }
}

contract NoxxTest is Test {
  Noxx internal noxx;
  TestABT internal noxxABT;
  TestVerifier internal noxxVerifier;

  address internal from;

  uint256[8] internal proof = [0, 1, 2, 3, 4, 5, 6, 7];
  uint256[1] internal input = [1];

  function setUp() public {
    noxxABT = new TestABT();
    noxxVerifier = new TestVerifier();
    noxx = new Noxx(noxxVerifier, noxxABT);
    from = vm.addr(0xA11CE);
  }

  function test_executeProofVerificationReturnsTrueWhenProofIsValid() public {
    bool result = noxx.executeProofVerification(proof, input, from);
    assertEq(result, true);
    bool isVerified = noxx.isVerifiedAccount(from);
    assertEq(isVerified, true);
  }

  function test_executeProofVerificationReturnsFailsWhenProofIsInvalid()
    public
  {
    uint256[1] memory invalidInput = [
      0x013840eb3fa139e182121fbf0d9a3ed55dbf9d76ca28c7523c2ca6206c834dae
    ];
    vm.expectRevert('Proof Verification failed');
    noxx.executeProofVerification(proof, invalidInput, from);
  }

  function test_isVerifiedAccountReturnsFalseWhenNotVerified() public {
    bool isVerified = noxx.isVerifiedAccount(from);
    assertEq(isVerified, false);
  }

  function test_mintNFTOnlyWhenAccountIsVerified() public {
    // verify
    bool result = noxx.executeProofVerification(proof, input, from);
    assertEq(result, true);

    noxx.mintNFT(from, 'tokenURI');
    assertEq(noxxABT.isMinted(from), true);
  }

  function test_mintNFTFailsWhenAccountIsNotVerified() public {
    vm.expectRevert('Not verified to mint NFT');
    noxx.mintNFT(from, 'tokenURI');
  }
}