// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Script.sol';
import '../src/TalentVerifierV2.sol';

contract TalentVerifierScript is Script {
  function setUp() public {}

  function run() public {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);
    new UltraVerifier();
    vm.stopBroadcast();
  }
}
