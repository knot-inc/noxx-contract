// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import '../TalentVerifier.sol';

contract TalentVerifierTest is Test {
  Verifier internal verifier;

  uint256[8] internal proof = [
    0x1fa192e58160f96250fd81b799a7cc9e9433ed2c18ae9a627b91ecc07813ebf5,
    0x24d8208af163e668a8d444851f5670dfe20157a0c672c4211950c4755b8adecd,
    0x10c6ac146b5666b31f12bd788cc2428c560e53d345128161d9536277cc3ff43a,
    0x1d86b5e1e9633982ce156854fcbdf8a9496a526d4885c87995795b606464d6a7,
    0x172c445b6177a2bb82f12f68e297850ed3c38affd10eab280265b1be69afa08c,
    0x0f2015f2c2fe8a559ac5017290961230f7f60f02696830798d8cd42387a39549,
    0x2ae7b76f317460ec244d97cfb3910c7816603f5e3ea39cc7816da014def46ef4,
    0x0b6441dd631fc69e693f82d5ffc1d2729e5a9fb1c9bbbe116f46e7322a3a9bc4
  ];
  uint256[4] internal input = [
    0x01633e8a7f2af0b95ee3aeea580087d212b3fb03369a12e5e5a3abee35282be7,
    0x214cb4160d21ab6bc0b5cb32ebc46299a0a7d50e14798fce0b4417804b05e6f8,
    0x0e040047cfde7e20ac531992e783a730211841fa9a9dbd21397b40d419cbb34f,
    0x12
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

  function test_verifyProofFailsWhenInputIsMalicious() public {
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
