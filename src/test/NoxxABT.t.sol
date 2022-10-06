// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import '../NoxxABT.sol';

contract NoxxABTTest is Test {
  NoxxABT internal abt;

  function setUp() public {
    abt = new NoxxABT();
  }

  function testInit() public {
    assertEq(abt.name(), 'Noxx');
    assertEq(abt.symbol(), 'NOXX');
    assertTrue(abt.hasRole(abt.MINT_ROLE(), address(this)));
    assertTrue(abt.hasRole(abt.DEFAULT_ADMIN_ROLE(), address(this)));
  }

  function testCanMint() public {
    abt.mint(address(1), 'https://test/0');
    assertEq(abt.balanceOf(address(1)), 1);
    assertEq(abt.tokenByOwner(address(1)), 1);
  }

  function testCannotMintAlreadyMinted() public {
    abt.mint(address(1), 'https://test/0');
    vm.expectRevert('Already minted');
    abt.mint(address(1), 'https://test/1');
  }

  function testCannotMintUnAuthorized() public {
    vm.prank(address(1));
    vm.expectRevert(
      'AccessControl: account 0x0000000000000000000000000000000000000001 is missing role 0x154c00819833dac601ee5ddded6fda79d9d8b506b911b3dbd54cdb95fe6c3686'
    );
    abt.mint(address(2), 'https://test/2');
  }

  function testCanUpdateTokenURI() public {
    abt.mint(address(1), 'https://test/0');
    assertEq(abt.tokenURI(1), 'https://test/0');

    abt.updateTokenURI(1, 'https://test/1');
    assertEq(abt.tokenURI(1), 'https://test/1');
  }

  function testCanBurnTokenByOwner() public {
    abt.mint(address(1), 'https://test/0');
    assertEq(abt.tokenURI(1), 'https://test/0');
    // switch to token owner
    vm.prank(address(1));
    abt.burn(1);
    assertEq(abt.balanceOf(address(1)), 0);
    assertEq(abt.tokenByOwner(address(1)), 0);
    vm.expectRevert("tokenURI: token doesn't exist");
    abt.tokenURI(1);
  }

  function testCannotBurnTokenIfTokenDoesNotExist() public {
    vm.expectRevert("ownerOf: token doesn't exist");
    // tokenID = 0 does not exist
    abt.burn(0);
  }

  function testCannotBurnTokenByNonOwnwer() public {
    abt.mint(address(1), 'https://test/0');
    assertEq(abt.tokenURI(1), 'https://test/0');
    vm.expectRevert('burn: sender must be owner');
    abt.burn(1);
  }

  function testCanPauseMint() public {
    abt.pause();
    vm.expectRevert('Pausable: paused');
    abt.mint(address(1), 'https://test/0');

    abt.unpause();
    abt.mint(address(1), 'https://test/0');
  }

  function testCanGrantRole() public {
    abt.grantRole(abt.MINT_ROLE(), address(100));
    vm.prank(address(100));
    abt.mint(address(1), 'https://test/0');
  }
}
