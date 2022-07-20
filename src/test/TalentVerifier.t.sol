// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import '../TalentVerifier.sol';

contract TalentVerifierTest is Test {
  Verifier internal verifier;

  uint256[8] internal proof = [
    0x1a30c521db62b4dd1586bb7c72d58360eb4544c8350f0f5b3eea2451ee414d4b,
    0x0883ddfc4430cdbcaca4fda0e84915140dc0ffe670cc2365a1f3891a993f2054,
    0x25618b8eb920e92cf5decf3dfaf4efa25be2ca5f7d58f3fa28215276bb654f7d,
    0x01124dbc452fe4ee2a86a46517d6a760ad4794b4bcbfc5f9fd8d7333657542d9,
    0x0daea1ea53e1652bb809ff8b3f3a9c9809a0b1597aebecad17ca04116e42e729,
    0x0967f1da0bedbade6cf2d4b855ffb25b6106912cd6e209a363c6eb176990de68,
    0x04296749456e72c7160fbfbd9fb57e7ae9bbcc62525e625860b48e435f91cadf,
    0x19ea66876adcca47c6d0a07920089f848270bd1ed09f2f3dd889d1955e656f19
  ];
  uint256[1] internal input = [
    0x01633e8a7f2af0b95ee3aeea580087d212b3fb03369a12e5e5a3abee35282be7
  ];

  function setUp() public {
    verifier = new Verifier();
  }

  function test_verifyProofReturnsTrueWhenInputIsCorrect() public {
    bool result = verifier.verifyProof(
      [proof[0], proof[1]],
      [[proof[2], proof[3]], [proof[4], proof[5]]],
      [proof[6], proof[7]],
      input
    );
    assertEq(result, true);
  }

  function test_cannotVerifyProofWhenInputIs() public {
    uint256[8] memory maliciousProof = [
      0x013840eb3fa139e182121fbf0d9a3ed55dbf9d76ca28c7523c2ca6206c834dae,
      0x1864e09609640bdad0b1989aff555f6068f4cb82c0e78cb9229647e3c5c55e98,
      0x2fee3a8be29cf71a4af42964b2417521d861f424d8c811d7c28aa0fbd7727932,
      0x0de899f6420be47da6c01be98996f946b3b49f0a10350f1c261d77ee99017101,
      0x0cf8df36b22ffbb1c45f6ee1e9f50faf0bbfdee42ec971d75fcb83ab0378ef04,
      0x2bdc5d5250ab2af50a1df2fccb8a4083fdfd04849499d1b0b9b4b830934325cf,
      0x1c1009458a26c30e76ceec120c79b820cda3da958e7382f67ca11c31ebeaa500,
      0x20974cdcbef1064175d771bfe3415e18e2d184faa10aefce6bad230c0b5d09a5
    ];
    bool result = verifier.verifyProof(
      [maliciousProof[0], maliciousProof[1]],
      [
        [maliciousProof[2], maliciousProof[3]],
        [maliciousProof[4], maliciousProof[5]]
      ],
      [maliciousProof[6], maliciousProof[7]],
      input
    );
    assertEq(result, false);
  }

  function test_cannotVerifyProofWhenInputIsIncorrect() public {
    vm.expectRevert();
    verifier.verifyProof(
      [proof[0], proof[1]],
      [[proof[2], proof[3]], [proof[4], proof[5]]],
      [
        proof[6],
        // incorrect hex value
        0x19ea66876adcca47c6d0a07920089f848270bd1ed09f2f3dd889d1955e656f10
      ],
      input
    );
  }
}
