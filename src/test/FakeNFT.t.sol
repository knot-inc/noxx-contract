// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../FakeNFT.sol";

contract FakeNFTTest is Test {
    FakeNFT internal fktn;

    function setUp() public {
        fktn = new FakeNFT();
    }

    function testInit() public {
        assertEq(fktn.name(), "fake");
        assertEq(fktn.symbol(), "FTKN");
        assertTrue(fktn.hasRole(fktn.MINT_ROLE(), address(this)));
        assertTrue(fktn.hasRole(fktn.DEFAULT_ADMIN_ROLE(), address(this)));
    }

    function testCanMint() public {
        fktn.mint(address(1), "https://test/0");
        assertEq(fktn.balanceOf(address(1)), 1);
    }

    function testCannotMintUnAuthorized() public {
        vm.prank(address(1));
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000001 is missing role 0x154c00819833dac601ee5ddded6fda79d9d8b506b911b3dbd54cdb95fe6c3686"
        );
        fktn.mint(address(2), "https://test/2");
    }

    function testCanUpdateTokenURI() public {
        fktn.mint(address(1), "https://test/0");
        assertEq(fktn.tokenURI(0), "https://test/0");

        fktn.updateTokenURI(0, "https://test/1");
        assertEq(fktn.tokenURI(0), "https://test/1");
    }

    function testCanBurnTokenByOwner() public {
        fktn.mint(address(1), "https://test/0");
        assertEq(fktn.tokenURI(0), "https://test/0");
        // switch to token owner
        vm.prank(address(1));
        fktn.burn(0);
        assertEq(fktn.balanceOf(address(1)), 0);
        vm.expectRevert("ERC721: invalid token ID");
        fktn.tokenURI(0);
    }

    function testCannotBurnTokenByNonOwnwer() public {
        fktn.mint(address(1), "https://test/0");
        assertEq(fktn.tokenURI(0), "https://test/0");
        vm.expectRevert("burn: sender must be owner");
        fktn.burn(0);
    }

    function testCanPauseMint() public {
        fktn.pause();
        vm.expectRevert("Pausable: paused");
        fktn.mint(address(1), "https://test/0");

        fktn.unpause();
        fktn.mint(address(1), "https://test/0");
    }

    function testCanGrantRole() public {
        fktn.grantRole(fktn.MINT_ROLE(), address(100));
        vm.prank(address(100));
        fktn.mint(address(1), "https://test/0");
    }
}
