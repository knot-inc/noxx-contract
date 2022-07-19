import path from 'path';
import fs from 'fs';
import {
  buildPoseidon,
  createPoseidonHash,
  encodeStringToBigInt,
} from './zk-tools/lib';

async function main() {
  const poseidon = await buildPoseidon();
  const commitment: bigint = encodeStringToBigInt('John Doe');
  const nonce: bigint = encodeStringToBigInt('1234');

  const hash = createPoseidonHash(poseidon, [commitment, nonce]);
  console.log({ commitment, nonce, hash });
  const input = {
    values: [commitment.toString()],
    nonces: [nonce.toString()],
    commits: [hash],
  };
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
