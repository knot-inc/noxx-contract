// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../Forwarder.sol";

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    bytes32 private constant _TYPEHASH =
        keccak256(
            "ForwardRequest(address from,address verifier,uint256 nonce)"
        );

    // computes the hash of a permit
    function getStructHash(Forwarder.ForwardRequest memory req)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(abi.encode(_TYPEHASH, req.from, req.verifier, req.nonce));
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(Forwarder.ForwardRequest memory _req)
        public
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_req)
                )
            );
    }
}
