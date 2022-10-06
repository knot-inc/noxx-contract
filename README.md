# Preparation

```
yarn install && yarn prepare
git submodule update --init --recursive
```

```
forge build
```

# Contract relationship

![relationship](https://user-images.githubusercontent.com/6277118/192703658-1b8a464d-dc10-4822-8784-1dfc3d992a52.png)

# Deploy Contract

- Make sure .env (for mumbai) .prodenv (for mainnet) is set properly

### build

```
forge build --build-info --build-info-path buildinfo.txt --use solc:0.8.13
```

### For mumbai test net(80001)

```
$ source .env
$ forge script script/FakeNFT.s.sol:FakeNFTScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
```

| Contract        | Address                                    |
| --------------- | ------------------------------------------ |
| FakeNFT         | 0x51a1B628d9a2CFb76306FDccb39E56382A64482B |
| TalentVerifier  | 0x479f7d70693a8d12db15f8415beb724ef223870f |
| VerifyForwarder | 0x8bb9c7c130aec8947a72ae5cd0d361b285a7b8c1 |
| NoxxABT         | 0xc8984bcf50fe9a864b5184bb83cfd968805067b7 |
| Noxx            | 0x27abf4e7daf06b52a953b27297fd30aa69cd539b |

### For main net(137)

```
$ source .prodenv
$ forge script --rpc-url $M_RPC_URL --verify --use solc:0.8.13 --private-key $M_PRIVATE_KEY --chain-id 137 --broadcast -vvvv --etherscan-api-key $M_SCAN_API_KEY script/Forwarder.s.sol:ForwarderScript
```

| Contract        | Address                                    |
| --------------- | ------------------------------------------ |
| FakeNFT         | -- NA --                                   |
| TalentVerifier  | 0x230A32770B8a339871D5EF1C63675BEc9e5D3404 |
| VerifyForwarder | 0x97b9333204bc6E53F9a1ff7794F01A10Cf1cdF52 |
| NoxxABT         | 0x34E51476a53AF4b6C5C6174c457cF3bC74C59193 |
| Noxx            | 0x52ae545990f3be7D44ed42b44b291C51bC676F7f |

# Verify

### For mumbai test net(80001)

```
$ forge verify-check --chain 80001 {GUID} --etherscan-key $SCAN_API_KEY
```

### For mainnet(137)

```
$ forge verify-check --chain 137 {GUID} --etherscan-key $M_SCAN_API_KEY
```

# Circuit

Install circom to your system. See https://docs.circom.io/getting-started/installation for the instruction

### 1. Generate final key, and export Verifier.sol and verification key

```
$ yarn ts-node node-script/generateFinalKey.ts
```

### 2. Generate proof

```
// convert r1cs to json
$ yarn snarkjs r1cs export json verifytalent.r1cs verifytalent.r1cs.json


// Generate witness
$ node verifytalent_js/generate_witness.js verifytalent.wasm input.json witness.wtns

// Generate the proof
$ yarn snarkjs groth16 prove verifytalent_final.zkey witness.wtns proof.json public.json
```

### 3. Verify the proof

```
$ yarn snarkjs groth16 verify verification_key.json public.json proof.json
[INFO]  snarkJS: OK!
```

### Appendix. Generate proof for Solidity

Generates Solidity inputs. Result will be in `input.txt`

```
$ TEST_TABLE_NAME={Table of MerkleTree}  yarn ts-node node-script/generateSolidityInputs.ts
```

# Updating submodule

The command below updates all submodules

```
git submodule update --recursive --remote --merge
```

# MerkleTree for CountryCode

See [MerkleTree](./CountryCodeMerkleTree.md)
