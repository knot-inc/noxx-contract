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

Contract Address: 0xc9991a0904206da66891156e83170fef61a27c19

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
