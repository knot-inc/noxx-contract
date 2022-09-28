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

- Make sure .env is set properly

### For mumbai test net(80001)

```
$ source .env
$ forge script script/FakeNFT.s.sol:FakeNFTScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
```

| Contract        | Address                                    |
| --------------- | ------------------------------------------ |
| FakeNFT         | 0xc9991a0904206da66891156e83170fef61a27c19 |
| TalentVerifier  | 0x479f7d70693a8d12db15f8415beb724ef223870f |
| VerifyForwarder | 0x8bb9c7c130aec8947a72ae5cd0d361b285a7b8c1 |
| NoxxABT         | 0x7c511681d8effda3c8695b8af8070c17b720a501 |
| Noxx            | 0x27abf4e7daf06b52a953b27297fd30aa69cd539b |

# Verify

### For mumbai test net(80001)

```
$ forge verify-contract --chain 80001 {ContractAddress} src/FakeNFT.sol:FakeNFT $SCAN_API_KEY
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
