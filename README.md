# Preparation

```
pnpm install && pnpm prepare
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
| Noxx            | 0x264b66f5113892AAEA263df76A140dF67c0f7554 |

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
| NoxxABT         | 0x0e5560636b320E07f6F88297276c8B60D7B31cFf |
| Noxx            | 0x15008034Ae7CB379f35A0C9CEfDA7b4C612c191c |

# Verify

### For mumbai test net(80001)

```
$ forge verify-check --chain 80001 {GUID} --etherscan-key $SCAN_API_KEY
```

### For mainnet(137)

```
$ forge verify-check --chain 137 {GUID} --etherscan-key $M_SCAN_API_KEY
```

# Zero-knowledge proof

## What is ZK proof

- A proof such that
  - A legal name from KYC matches given user inputs
  - Age is over 18
  - A residential country is not restricted to work with a company in the US(Noxx)

## Workflow

![](https://github.com/knot-inc/noxx-contract/blob/main/zkp-workflow.png)

## Circuits

Circuit is written in Noir:[here](https://github.com/knot-inc/noxx-contract/blob/main/circuit_v2/src/main.noir)

- Private inputs
  - name
  - residential country(from tax document)
  - age(based on their DOB)
  - nonce(Generated in the local PC to ensure the values have not been tampered)
- Public inputs
  - commitments that are paired with private inputs. Generated with `poseidonHash(val, nonce)`
  - age: 18, we expect this user is above 18
- Verification
  - Checks `poseidonHash(value, nonce) == commitment` for each field
  - Checks range proof for `age`
  - Checks `country` is in the Merkle tree of allowed countries (see [MerkleTree](https://github.com/knot-inc/noxx-contract/blob/main/CountryCodeMerkleTree.md))

## Development

Install Noir to your system. See https://noir-lang.org/ for the instruction. 0.7.1+ is required.

### 1. Generate Verifier.sol

```
$ nargo codegen-verifier
```

Place it under `src/`

```
cp plonk_vk.sol src/TalentVerifierV2.sol
```

### 2. Generate proof

Prepare Prover.toml

```
$ nargo prove p
```

This will generate `proofs/p.proof`

### 3. Verify the proof

```
$ nargo verify p
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
