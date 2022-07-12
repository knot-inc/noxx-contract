// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../helpers/SigUtils.sol";
import "../Forwarder.sol";
import "../interfaces/IVerifier.sol";

contract Verifier is IVerifier {
    // No parameters required
    // https://forum.openzeppelin.com/t/unused-function-parameter-in-overriding-function-how-to-avoid-compiler-warning/20883
    function verifyProof(
        uint256[2] memory,
        uint256[2][2] memory,
        uint256[2] memory,
        uint256[1] memory
    ) external pure override returns (bool) {
        return true;
    }
}

contract ForwarderTest is Test {
    SigUtils internal sigUtils;
    Forwarder internal forwarder;
    Verifier internal verifier;

    uint256 internal userPrivateKey;
    uint256 internal spenderPrivateKey;
    uint256 internal otherPrivateKey;

    address internal user;
    address internal spender;

    uint256[8] internal proof = [0, 1, 2, 3, 4, 5, 6, 7];
    uint256 internal input = 1;

    function setUp() public {
        verifier = new Verifier();
        forwarder = new Forwarder("VerifyForwarder", "1.0.0");

        sigUtils = new SigUtils(forwarder.DOMAIN_SEPARATOR());

        userPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;
        otherPrivateKey = 0xCa123;

        user = vm.addr(userPrivateKey);
        spender = vm.addr(spenderPrivateKey);
        // 0xe05fcc23807536bee418f142d19fa0d21bb0cff7
        emit log_address(user);
        // 0x185a4dc360ce69bdccee33b3784b0282f7961aea
        emit log_address(address(forwarder));

        input = 1;
    }

    function test_canExecuteWhenInputIsCorrect() public {
        Forwarder.ForwardRequest memory req = Forwarder.ForwardRequest({
            from: user,
            verifier: address(verifier),
            nonce: 0
        });

        bytes32 digest = sigUtils.getTypedDataHash(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        bool result = forwarder.execute(req, proof, input, v, r, s);
        // Contract being executed by Forwarder
        assertEq(result, true);
    }

    function test_canExecuteWhenSpenderIsWhiteListed() public {
        forwarder.addSenderToWhitelist(spender);
        Forwarder.ForwardRequest memory req = Forwarder.ForwardRequest({
            from: user,
            verifier: address(verifier),
            nonce: 0
        });

        bytes32 digest = sigUtils.getTypedDataHash(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        vm.prank(spender);
        bool result = forwarder.execute(req, proof, input, v, r, s);
        // Contract being executed by Forwarder
        assertEq(result, true);
    }

    function test_canExecuteWhenNonceIsUpdated() public {
        uint256 nonce_1 = forwarder.getNonce(user);
        Forwarder.ForwardRequest memory req = Forwarder.ForwardRequest({
            from: user,
            verifier: address(verifier),
            nonce: nonce_1
        });
        emit log_uint(nonce_1);
        bytes32 digest = sigUtils.getTypedDataHash(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        forwarder.execute(req, proof, input, v, r, s);

        uint256 nonce_2 = forwarder.getNonce(user);
        emit log_uint(nonce_2);
        Forwarder.ForwardRequest memory req_2 = Forwarder.ForwardRequest({
            from: user,
            verifier: address(verifier),
            nonce: nonce_2
        });
        bytes32 digest_2 = sigUtils.getTypedDataHash(req_2);
        (uint8 v_2, bytes32 r_2, bytes32 s_2) = vm.sign(
            userPrivateKey,
            digest_2
        );
        bool result = forwarder.execute(req_2, proof, input, v_2, r_2, s_2);
        assertEq(result, true);
    }

    function test_cannotExecuteWhenNonceIsUsedTwice() public {
        Forwarder.ForwardRequest memory req = Forwarder.ForwardRequest({
            from: user,
            verifier: address(verifier),
            nonce: 0
        });

        bytes32 digest = sigUtils.getTypedDataHash(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        forwarder.execute(req, proof, input, v, r, s);
        vm.expectRevert("Forwarder: nonce is used");
        forwarder.execute(req, proof, input, v, r, s);
    }

    function test_cannotExecuteWhenSignatureIncorrect() public {
        Forwarder.ForwardRequest memory req = Forwarder.ForwardRequest({
            from: user,
            verifier: address(verifier),
            nonce: 0
        });
        bytes32 digest = sigUtils.getTypedDataHash(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(otherPrivateKey, digest);

        vm.expectRevert("Forwarder: signature does not match request");
        forwarder.execute(req, proof, input, v, r, s);
    }

    function test_cannotExecuteWhenNotInwhiteList() public {
        Forwarder.ForwardRequest memory req = Forwarder.ForwardRequest({
            from: user,
            verifier: address(verifier),
            nonce: 0
        });

        bytes32 digest = sigUtils.getTypedDataHash(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        vm.prank(vm.addr(0xD001));
        vm.expectRevert(
            "Forwarder: sender of meta-transaction is not whitelisted"
        );
        forwarder.execute(req, proof, input, v, r, s);
    }
}
