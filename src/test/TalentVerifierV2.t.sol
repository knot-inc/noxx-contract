// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import '../../circuit_v2/contract/main/plonk_vk.sol';

contract TalentVerifierTestV2 is Test {
  UltraVerifier public verifier;

  bytes32[] public correct = new bytes32[](1);
  bytes32[] public wrong = new bytes32[](1);

  function setUp() public {
    verifier = new UltraVerifier();
  }

  function testVerifyProof() public view {
    string memory proof = vm.readLine('./circuit_v2/proofs/main.proof');
    bytes memory proofBytes = vm.parseBytes(proof);
    bytes32[] memory publicInputs = new bytes32[](4);
    publicInputs[0] = bytes32(
      0x2ca8546807e6355a4a01dbce024fd82c0ff9fd50d426da6dfdd6faf17aa15b9d
    );
    publicInputs[1] = bytes32(
      0x137f7ec30b7b7a9d88649ae6d5f80ba2c974d5b80f2ea169efa95a44685ff143
    );
    publicInputs[2] = bytes32(
      0x08d6eacdd52aecdcc5f411ef9d456a330bbe8e47fc2b1a686216b16f1b1303fe
    );

    // 20 in hex
    publicInputs[3] = bytes32(
      0x0000000000000000000000000000000000000000000000000000000000000012
    );
    bool proofResult = verifier.verify(proofBytes, publicInputs);
    require(proofResult, 'Proof is not valid');
  }

  function test_WrongProof() public {
    vm.expectRevert();
    string memory proof = vm.readLine('./circuit_v2/proofs/main.proof');
    bytes memory proofBytes = vm.parseBytes(proof);
    bytes32[] memory publicInputs = new bytes32[](4);
    publicInputs[0] = bytes32(
      0x2ca8546807e6355a4a01dbce024fd82c0ff9fd50d426da6dfdd6faf17aa15b9d
    );
    publicInputs[1] = bytes32(
      0x137f7ec30b7b7a9d88649ae6d5f80ba2c974d5b80f2ea169efa95a44685ff143
    );
    publicInputs[2] = bytes32(
      0x08d6eacdd52aecdcc5f411ef9d456a330bbe8e47fc2b1a686216b16f1b1303fe
    );

    // 32 in hex. Since the private input is 20 it should fail
    publicInputs[3] = bytes32(
      0x0000000000000000000000000000000000000000000000000000000000000020
    );
    bool proofResult = verifier.verify(proofBytes, publicInputs);
    assert(proofResult == false);
  }
}
