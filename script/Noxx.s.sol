// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Script.sol';
import '../src/Noxx.sol';
import '../src/TalentVerifier.sol';
import '../src/NoxxABT.sol';
import '../src/interfaces/INoxxABT.sol';
import '../src/interfaces/IVerifier.sol';

contract NoxxScript is Script {
  address internal noxxABT;
  address internal talentVerifier;

  function setUp() public {
    if (block.chainid == 80001) {
      // Fake NFT for test environment
      noxxABT = 0xc9991A0904206da66891156e83170fEf61A27C19;
    } else {
      noxxABT = 0x6bbF732B5d9d364116a10B248b3E09B9ce580C54;
    }
    talentVerifier = 0x479F7D70693A8d12dB15F8415BeB724eF223870f;
  }

  function run() public {
    vm.broadcast();
    new Noxx(IVerifier(talentVerifier), INoxxABT(noxxABT));
    vm.stopBroadcast();
  }
}
