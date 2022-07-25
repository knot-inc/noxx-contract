# Preparation

```
yarn install && yarn prepare

```

```
forge build
```

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
| TalentVerifier  | 0x6bbf732b5d9d364116a10b248b3e09b9ce580c54 |
| VerifyForwarder | 0x3d26857ca23dc747520af6e3216f1d3bba870558 |
| NoxxABT         | 0x7c511681d8effda3c8695b8af8070c17b720a501 |
| Noxx            | 0x4f5e3d61c4bb929e844c7702acde5f6ba78d8a57 |

# Verify

### For mumbai test net(80001)

```
$ forge verify-contract --chain 80001 {ContractAddress} src/FakeNFT.sol:FakeNFT $SCAN_API_KEY
```

# Circuit

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

# Updating submodule

The command below updates all submodules

```
git submodule update --recursive --remote --merge
```
