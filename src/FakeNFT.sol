// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/INoxxABT.sol";

/// @title NFT Contract that mimics NoxxABT except non-transferable
contract FakeNFT is INoxxABT, ERC721URIStorage, Pausable, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private supplyCounter;
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");

    constructor() ERC721("fake", "FTKN") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINT_ROLE, msg.sender);
    }

    function mint(address to, string memory _tokenURI)
        external
        whenNotPaused
        onlyRole(MINT_ROLE)
    {
        _mint(to, totalSupply());

        _setTokenURI(totalSupply(), _tokenURI);

        supplyCounter.increment();
    }

    function updateTokenURI(uint256 _tokenId, string memory _tokenURI)
        external
        onlyRole(MINT_ROLE)
    {
        _setTokenURI(_tokenId, _tokenURI);
    }

    function totalSupply() public view returns (uint256) {
        return supplyCounter.current();
    }

    /// @dev Pausing/resuming only allowed for admin
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /// @dev Pausing/resuming only allowed for admin
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /// @dev See ERC4973 Contract
    function burn(uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "burn: sender must be owner");
        _burn(_tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
