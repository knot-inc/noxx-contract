import { ethers, providers, Wallet } from 'ethers';
const alchemyApiKey = process.env.ALCHEMY_KEY;
// Wallet key is the one who signs thus it should be the `from` account
const walletKey = process.env.SIGNER_WALLET_KEY as string;

export const genSignature = async ({
  from,
  verifierContract,
  forwarderContract,
}: {
  from: string;
  verifierContract: string;
  forwarderContract: string;
}) => {
  const wallet = new Wallet(walletKey);
  const provider = new providers.AlchemyProvider('maticmum', alchemyApiKey);
  console.log({ walletPubKey: wallet.publicKey });

  const domain = {
    name: 'VerifyForwarder',
    version: '1.0.0',
    chainId: 80001, // mumbai
    forwarderContract,
  };

  const types = {
    ForwardRequest: [
      {
        internalType: 'address',
        name: 'from',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'verifier',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: 'nonce',
        type: 'uint256',
      },
    ],
  };

  const value = {
    from,
    verifier: verifierContract,
    nonce: 0,
  };
  const signature = await wallet
    .connect(provider)
    ._signTypedData(domain, types, value);
  console.log(signature);
  // split signature
  const r = signature.slice(0, 66);
  const s = '0x' + signature.slice(66, 130);
  const v = parseInt(signature.slice(130, 132), 16);
  console.log({ r, s, v });
  const sig = ethers.utils.splitSignature(signature);
  console.log(sig);
  return true;
};

// Call `yarn ts-node node-script/generateSignature.ts 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 0x92c99bbf8fd2d569c159bc525de2f80d1a27cc17 0x9df5a1d59df0b88f63f280d4ad95b238a885e391`
console.log(
  `from ${process.argv[2]}, VerifierContract: ${process.argv[3]}, ForwarderContract: ${process.argv[4]}`,
);

genSignature({
  from: process.argv[2],
  verifierContract: process.argv[3],
  forwarderContract: process.argv[4],
}).then(() => {
  console.log('end');
});
