// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../NoxxERC721.sol";

contract NoxxERC721Test is Test {
    NoxxERC721 internal nft;

    function setUp() public {
        nft = new NoxxERC721();
    }

    function testInit() public {
        assertEq(nft.name(), "Noxx");
        assertEq(nft.symbol(), "NOXX");
        assertTrue(nft.hasRole(nft.MINT_ROLE(), address(this)));
        assertTrue(nft.hasRole(nft.DEFAULT_ADMIN_ROLE(), address(this)));
    }

    function testCanMint() public {
        nft.mint(address(1), "https://test/0");
        assertEq(nft.balanceOf(address(1)), 1);
    }

    function testCannotMintAlreadyMinted() public {
        nft.mint(address(1), "https://test/0");
        vm.expectRevert("Already minted");
        nft.mint(address(1), "https://test/1");
    }

    function testCannotMintUnAuthorized() public {
        vm.prank(address(1));
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000001 is missing role 0x154c00819833dac601ee5ddded6fda79d9d8b506b911b3dbd54cdb95fe6c3686"
        );
        nft.mint(address(2), "https://test/2");
    }

    function testCanUpdateTokenURI() public {
        nft.mint(address(1), "https://test/0");
        assertEq(nft.tokenURI(0), "https://test/0");

        nft.updateTokenURI(0, "https://test/1");
        assertEq(nft.tokenURI(0), "https://test/1");
    }
}
