// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13 <0.9.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC4973.sol";
import "./ERC4973URIStorage.sol";
import "./interfaces/INoxxABT.sol";

/// @title NoxxABT is Account bound Token
/// @dev Token can be minted only once per address. Properties are updated through tokenURI
contract NoxxABT is
    INoxxABT,
    ERC4973,
    ERC4973URIStorage,
    Pausable,
    AccessControl
{
    using Counters for Counters.Counter;

    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    Counters.Counter private supplyCounter;

    constructor() ERC4973("Noxx", "NOXX") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINT_ROLE, msg.sender);
    }

    /// @dev See {INoxxABT-mint}.
    function mint(address to, string memory _tokenURI)
        external
        whenNotPaused
        onlyRole(MINT_ROLE)
    {
        require(balanceOf(to) == 0, "Already minted");
        // uri in ERC4973 is not used
        _mint(to, totalSupply(), "");
        _setTokenURI(totalSupply(), _tokenURI);

        supplyCounter.increment();
    }

    /// @dev See {INoxxABT-updateTokenURI}
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
        override(ERC4973, AccessControl)
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

    /// @dev if a token-specific URI was set for the token, and if so, it deletes the token URI from the storage mapping
    function _burn(uint256 tokenId)
        internal
        override(ERC4973, ERC4973URIStorage)
    {
        super._burn(tokenId);
    }

    /// @dev return tokenURI stored
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC4973, ERC4973URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
