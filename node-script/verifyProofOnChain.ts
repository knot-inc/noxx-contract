import 'dotenv/config';
import fs from 'fs';
// import path from 'path';
import generateSolidityInputs from './generateSolidityInputsV2.js';
import { ethers, providers, Wallet } from 'ethers';

const alchemyApiKey = process.env.ALCHEMY_KEY;
// Wallet key is the one who signs thus it should be the `from` account
const walletKey = process.env.SIGNER_WALLET_KEY as string;

const env = process.env.ENV || 'local';

const verifierABI = JSON.parse(
  fs.readFileSync('./out/plonk_vk.sol/UltraVerifier.json', 'utf8'),
).abi;

export const verifyProofOnChain = async ({
  verifierContract,
}: {
  verifierContract: string;
}) => {
  console.log('env', env);
  let provider =
    env === 'local'
      ? new providers.JsonRpcProvider('http://127.0.0.1:8545')
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

  // setup inputs. Either directly call generateSolidityInputsV2 or read from file
  // const filepath = path.join('./node-script', 'input.txt');
  // const str = fs.readFileSync(filepath, 'utf-8');
  // const inputs = JSON.parse(str);
  // const proof = Uint8Array.from(Buffer.from(inputs.proof, 'hex'));
  // const publicInputs = Uint8Array.from(Buffer.from(inputs.inputs, 'hex'));
  const { proof, publicInputs } = await generateSolidityInputs();
  console.log('publicInputs', publicInputs.length);
  const contract = new ethers.Contract(verifierContract, verifierABI, wallet);
  const result = await contract
    .connect(wallet)
    .verify(proof, [
      publicInputs.slice(0, 32),
      publicInputs.slice(32, 64),
      publicInputs.slice(64, 96),
      publicInputs.slice(96, 128),
    ]);
  console.log('result', result);
  return true;
};

// Call `pnpm ts-node --esm node-script/verifyProofOnChain.ts <verifierContract>`
console.log(`VerifierContract: ${process.argv[2]}`);

verifyProofOnChain({
  verifierContract: process.argv[2],
}).then(() => {
  console.log('end');
});
