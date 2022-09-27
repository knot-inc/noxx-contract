# MerkleTree for Country Code

We verify that Talent is not from counties which the US prohibits to work with. We confirm by checking the Merkle Proof of a Tree which has non-restricted countries's ISO code as leaves.

The circuit also checks nonce passed from the prover to make sure the proof has not been modified.

# Seeding

TEST_TABLE_NAME points to your Table

```
TEST_TABLE_NAME=TempStack-MerkleTreeDBMerkleTree3F9A2B5E-11V6XWNRSHDI5 PROFILE=noxx  yarn ts-node node-script/seedingCountryCodeHashes.ts
```

# Generate MerkleProof

Set CountryCode which you want to make MerkleProof

```
TEST_TABLE_NAME=TempStack-MerkleTreeDBMerkleTree3F9A2B5E-11V6XWNRSHDI5 PROFILE=noxx  yarn ts-node node-script/generateCountryCodeMerkleProof.ts AX
```
