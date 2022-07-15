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
