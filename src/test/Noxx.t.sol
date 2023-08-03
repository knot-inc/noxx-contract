// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import '../interfaces/INoxxABT.sol';
import '../interfaces/IUltraVerifier.sol';
import '../Noxx.sol';

contract TestVerifier is IUltraVerifier {
  function verify(
    bytes memory,
    bytes32[] memory publicInputs
  ) external pure returns (bool) {
    return (publicInputs[3] ==
      bytes32(
        0x0000000000000000000000000000000000000000000000000000000000000012
      ));
  }
}

contract TestABT is INoxxABT {
  mapping(address => bool) private minted;

  function mint(address to, string memory) external {
    minted[to] = true;
  }

  function updateTokenURI(uint256 tokenId, string memory tokenURI) external {}

  function tokenByOwner(address owner) external pure returns (uint256) {
    require(owner != address(0));
    return 0;
  }

  /// @dev See {INoxxABT-tokenURIByOwner}.
  function tokenURIByOwner(
    address owner
  ) external pure returns (string memory) {
    require(owner != address(0));
    return '';
  }

  function isMinted(address to) public view returns (bool) {
    return minted[to];
  }
}

contract NoxxTest is Test {
  Noxx internal noxx;
  TestABT internal noxxABT;
  TestVerifier internal noxxVerifier;

  address internal from;

  string internal proofStr = vm.readLine('./circuit_v2/proofs/p.proof');
  bytes internal proof = vm.parseBytes(proofStr);
  bytes32[] internal input = [
    bytes32(0x2ca8546807e6355a4a01dbce024fd82c0ff9fd50d426da6dfdd6faf17aa15b9d),
    bytes32(0x137f7ec30b7b7a9d88649ae6d5f80ba2c974d5b80f2ea169efa95a44685ff143),
    bytes32(0x08d6eacdd52aecdcc5f411ef9d456a330bbe8e47fc2b1a686216b16f1b1303fe),
    bytes32(0x0000000000000000000000000000000000000000000000000000000000000012)
  ];

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
    bytes32[] memory invalidInput = new bytes32[](4);

    invalidInput[0] = bytes32(
      0x2ca8546807e6355a4a01dbce024fd82c0ff9fd50d426da6dfdd6faf17aa15b9d
    );
    invalidInput[1] = bytes32(
      0x137f7ec30b7b7a9d88649ae6d5f80ba2c974d5b80f2ea169efa95a44685ff143
    );
    invalidInput[2] = bytes32(
      0x08d6eacdd52aecdcc5f411ef9d456a330bbe8e47fc2b1a686216b16f1b1303fe
    );
    invalidInput[3] = bytes32(
      0x0000000000000000000000000000000000000000000000000000000000000022
    );
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
