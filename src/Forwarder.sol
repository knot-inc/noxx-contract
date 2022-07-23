// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import '@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import './interfaces/INoxx.sol';

/**
 * @title Forwarder Smart Contract
 * @dev forwarder for meta-transaction forwarding. Allows forwarder to execute tx on behalf of users
 * Reference: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/metatx/MinimalForwarder.sol
 */

contract Forwarder is Ownable, Pausable, EIP712 {
  using ECDSA for bytes32;

  struct ForwardRequest {
    address from; // Externally-owned account (EOA) making the request.
    address verifier; // A smart contract to execute.
    uint256 nonce; // On-chain tracked nonce of a transaction.
  }

  bytes32 private constant _TYPEHASH =
    keccak256('ForwardRequest(address from,address verifier,uint256 nonce)');

  mapping(address => uint256) private _nonces;
  mapping(address => bool) private _senderWhitelist;

  event MetaTransactionExecuted(
    address indexed from,
    address indexed verifier,
    bool indexed verified
  );
  event AddressWhitelisted(address indexed sender);
  event AddressRemovedFromWhitelist(address indexed sender);

  //debug
  event DebugVerify(
    ForwardRequest req,
    uint8 v,
    bytes32 r,
    bytes32 s,
    address signer
  );

  constructor(string memory name, string memory version) EIP712(name, version) {
    address msgSender = msg.sender;
    addSenderToWhitelist(msgSender);
  }

  /**
   * @dev Triggers stopped state.
   * Requirements: The contract must not be paused.
   */
  function pause() public onlyOwner {
    _pause();
  }

  /**
   * @dev Returns to normal state.
   * Requirements: The contract must be paused.
   */
  function unpause() public onlyOwner {
    _unpause();
  }

  /**
   * @dev Returns the domain separator used in the encoding of the signature for `execute`, as defined by {EIP712}.
   * See https://eips.ethereum.org/EIPS/eip-712
   */
  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view returns (bytes32) {
    return _domainSeparatorV4();
  }

  /// @dev Retrieves the on-chain tracked nonce of an EOA making the request.
  function getNonce(address from) public view returns (uint256) {
    return _nonces[from];
  }

  /**
   * @dev Verifies the signature based on typed structured data.
   * See https://eips.ethereum.org/EIPS/eip-712
   */
  function _verify(
    ForwardRequest calldata req,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public view returns (bool) {
    address signer = ECDSA.recover(
      _hashTypedDataV4(
        keccak256(abi.encode(_TYPEHASH, req.from, req.verifier, req.nonce))
      ),
      v,
      r,
      s
    );
    return signer == req.from;
  }

  /// @dev execute with signature
  function executeWithSignature(
    ForwardRequest calldata req,
    uint256[8] calldata proof,
    uint256[1] calldata input,
    bytes memory signature
  ) public payable whenNotPaused returns (bool) {
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    return execute(req, proof, input, v, r, s);
  }

  /// @dev Main function; executes the meta-transaction via a low-level call.
  function execute(
    ForwardRequest calldata req,
    uint256[8] calldata proof,
    uint256[1] calldata input,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public payable whenNotPaused returns (bool) {
    require(_nonces[req.from] == req.nonce, 'Forwarder: nonce is used');
    require(
      _senderWhitelist[msg.sender],
      'Forwarder: sender of meta-transaction is not whitelisted'
    );

    require(
      _verify(req, v, r, s),
      'Forwarder: signature does not match request'
    );
    _nonces[req.from] = req.nonce + 1;

    bool verified = _verifyProof(req.from, req.verifier, proof, input);

    emit MetaTransactionExecuted(req.from, req.verifier, verified);

    return verified;
  }

  /// @dev Verify zk proof
  function _verifyProof(
    address from,
    address verifier,
    uint256[8] calldata proof,
    uint256[1] calldata input
  ) internal returns (bool) {
    INoxx noxxContract = INoxx(verifier);
    return noxxContract.executeProofVerification(proof, input, from);
  }

  /// @dev Only whitelisted addresses are allowed to broadcast meta-transactions.
  function addSenderToWhitelist(address sender) public onlyOwner {
    require(
      !isWhitelisted(sender),
      'Forwarder: sender address is already whitelisted'
    ); // This requirement prevents registry duplication.
    _senderWhitelist[sender] = true;
    emit AddressWhitelisted(sender);
  }

  /// @dev Removes a whitelisted address.
  function removeSenderFromWhitelist(address sender) public onlyOwner {
    _senderWhitelist[sender] = false;
    emit AddressRemovedFromWhitelist(sender);
  }

  /// @dev Retrieves the information whether an address is whitelisted or not.
  function isWhitelisted(address sender) public view returns (bool) {
    return _senderWhitelist[sender];
  }
}
