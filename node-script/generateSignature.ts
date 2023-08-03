import 'dotenv/config';
import { ethers, providers, Wallet } from 'ethers';
import forwarderABI from '../abi/Forwarder.json';

const alchemyApiKey = process.env.ALCHEMY_KEY;
// Wallet key is the one who signs thus it should be the `from` account
const walletKey = process.env.SIGNER_WALLET_KEY as string;

const env = process.env.ENV || 'local';

export const genSignature = async ({
  from,
  verifierContract,
  forwarderContract,
}: {
  from: string;
  verifierContract: string;
  forwarderContract: string;
}) => {
  console.log('env', env);
  let provider =
    env === 'local'
      ? new providers.JsonRpcProvider('http://localhost:8545')
      : new providers.AlchemyProvider('maticmum', alchemyApiKey);
  const wallet = new Wallet(
    env === 'local'
      ? '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d'
      : walletKey,
  ).connect(provider);
  console.log({
    walletPubKey: wallet.address,
    provider: provider.connection.url,
  });

  const domain = {
    name: 'VerifyForwarder',
    version: '1.0.0',
    // chainId: 80001, // mumbai
    chainId: 31337, // hardhat
    verifyingContract: forwarderContract,
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

  // get nonce from the network
  const contract = new ethers.Contract(forwarderContract, forwarderABI, wallet);
  console.log('contract', contract);
  const isPaused = await contract.paused();
  console.log('isPaused', isPaused);
  const getNonceTx = await contract.connect(wallet).getNonce(from);
  const nonce = getNonceTx.toNumber();
  console.log('Next nonce', nonce);

  const value = {
    from,
    verifier: verifierContract,
    nonce,
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

// Call `yarn ts-node node-script/generateSignature.ts 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 0x4f5e3d61c4bb929e844c7702acde5f6ba78d8a57 0x3d26857ca23dc747520af6e3216f1d3bba870558`
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
