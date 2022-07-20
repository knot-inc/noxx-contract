// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Script.sol';
import '../src/NoxxABT.sol';

contract NoxxABTScript is Script {
  function setUp() public {}

  function run() public {
    vm.broadcast();
    new NoxxABT();
    vm.stopBroadcast();
  }
}
