import path from 'path';
import fs from 'fs';
import {
  buildPoseidon,
  createPoseidonHash,
  encodeStringToBigInt,
} from './zk-tools/lib';
import { generateMerkleProof } from './utils/generateMerkleProof';
import { BigNumber } from 'ethers';

async function main() {
  const poseidon = await buildPoseidon();
  const name: bigint = encodeStringToBigInt('John Doe');
  const age: bigint = BigNumber.from(20) as unknown as bigint;
  const country: bigint = encodeStringToBigInt('JP');
  const nonce: bigint = encodeStringToBigInt('1234');

  const commits = [name, age, country].map((v) =>
    createPoseidonHash(poseidon, [v, nonce]).toString(),
  );
  const merkleProof = await generateMerkleProof('JP');
  const input = {
    values: [name, age, country].map((v) => v.toString()),
    nonces: [nonce.toString(), nonce.toString(), nonce.toString()],
    commits,
    age: 18,
    ...merkleProof,
  };
  console.log({ input });
  // write to file
  const inputPath = path.join(__dirname, `/../circuit/`, 'input.json');
  if (fs.existsSync(inputPath)) {
    fs.unlinkSync(inputPath);
  }
  fs.openSync(inputPath, 'w');
  fs.writeFileSync(inputPath, JSON.stringify(input));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
