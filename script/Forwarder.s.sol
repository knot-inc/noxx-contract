// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Script.sol';
import '../src/Forwarder.sol';

contract ForwarderScript is Script {
  function setUp() public {}

  function run() public {
    vm.broadcast();
    new Forwarder('VerifyForwarder', '1.0.0');
    vm.stopBroadcast();
  }
}
