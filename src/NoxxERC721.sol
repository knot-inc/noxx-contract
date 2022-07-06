// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./INoxxERC721.sol";

// NoxxERC721 is Semi-Soulbound Token
// - Only the minter role can transfer tokens
// - Token can be minted only once per address. Properties are updated through tokenURI
contract NoxxERC721 is
    INoxxERC721,
    ERC721,
    ERC721URIStorage,
    Pausable,
    AccessControl
{
    using Counters for Counters.Counter;

    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    Counters.Counter private supplyCounter;

    constructor() ERC721("Noxx", "NOXX") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINT_ROLE, msg.sender);
    }

    /// @dev See {INoxxERC721-mint}.
    function mint(address to, string memory _tokenURI)
        external
        onlyRole(MINT_ROLE)
    {
        require(balanceOf(to) == 0, "Already minted");
        _safeMint(to, totalSupply());
        _setTokenURI(totalSupply(), _tokenURI);

        emit Minted(totalSupply(), to);

        supplyCounter.increment();
    }

    /// @dev See {INoxxERC721-updateTokenURI}
    function updateTokenURI(uint256 tokenId, string memory _tokenURI)
        external
        onlyRole(MINT_ROLE)
    {
        // internally checks the existence of tokenId
        _setTokenURI(tokenId, _tokenURI);
    }

    function totalSupply() public view returns (uint256) {
        return supplyCounter.current();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// @dev Pausing/resuming only allowed for admin
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /// @dev Pausing/resuming only allowed for admin
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // Internal functions

    /// @dev
    /// Do not allow token holders to transfer token
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused onlyRole(MINT_ROLE) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /// @dev if a token-specific URI was set for the token, and if so, it deletes the token URI from the storage mapping
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    /// @dev return tokenURI stored
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
