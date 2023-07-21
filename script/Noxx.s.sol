// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Script.sol';
import '../src/Noxx.sol';
import '../src/TalentVerifierV2.sol';
import '../src/NoxxABT.sol';
import '../src/interfaces/INoxxABT.sol';
import '../src/interfaces/IUltraVerifier.sol';

contract NoxxScript is Script {
  address internal noxxABT;
  address internal talentVerifier;

  function setUp() public {
    if (block.chainid == 80001) {
      // Fake NFT for test environment
      noxxABT = 0x51a1B628d9a2CFb76306FDccb39E56382A64482B;
    } else if (block.chainid == 137) {
      noxxABT = 0x0e5560636b320E07f6F88297276c8B60D7B31cFf;
    }

    if (block.chainid == 80001) {
      talentVerifier = 0x479F7D70693A8d12dB15F8415BeB724eF223870f;
    } else if (block.chainid == 137) {
      talentVerifier = 0x230A32770B8a339871D5EF1C63675BEc9e5D3404;
    }
  }

  function run() public {
    vm.broadcast();
    new Noxx(IUltraVerifier(talentVerifier), INoxxABT(noxxABT));
    vm.stopBroadcast();
  }
}
