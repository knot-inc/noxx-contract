import path from 'path';
import fs from 'fs';
import { BigNumber } from 'ethers';
import {
  buildPoseidon,
  createPoseidonHash,
  encodeStringToBigInt,
  generateGroth16Proof,
  packToSolidityProof,
} from './zk-tools/lib';

// Generate Solidity inputs for testing purpose
async function main() {
  // Create inputs
  const poseidon = await buildPoseidon();
  const commitment: bigint = encodeStringToBigInt('Chris Nye');
  const nonce: bigint = encodeStringToBigInt('5678');

  const hash = createPoseidonHash(poseidon, [commitment, nonce]);
  console.log({ commitment, nonce, hash });
  const witness = {
    values: [commitment.toString()],
    nonces: [nonce.toString()],
    commits: [hash],
  };

  const wasmFilePath = './circuit/verifytalent.wasm';
  const finalZKeyPath = './circuit/verifytalent_final.zkey';
  // Generate Proof
  const { proof, publicSignals } = await generateGroth16Proof({
    witness,
    wasmFilePath,
    finalZKeyPath,
  });

  console.log(proof);
  console.log(publicSignals);
  const solidityProof = packToSolidityProof(proof);
  const hexProof = solidityProof.map((v) => BigNumber.from(v).toHexString());
  // write to file
  const inputPath = path.join(__dirname, 'input.txt');
  if (fs.existsSync(inputPath)) {
    fs.unlinkSync(inputPath);
  }
  const input = BigNumber.from(publicSignals[0]).toHexString();
  fs.openSync(inputPath, 'w');
  fs.writeFileSync(
    inputPath,
    JSON.stringify({
      proof: hexProof,
      input,
    }),
  );

  return;
}

main()
  .then(() => {
    process.exitCode = 0;
  })
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
