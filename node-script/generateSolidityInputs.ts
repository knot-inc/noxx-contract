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
import { generateMerkleProof } from './utils/generateMerkleProof';

// Generate Solidity inputs for testing purpose
async function main() {
  // Create inputs
  const poseidon = await buildPoseidon();
  const name: bigint = encodeStringToBigInt('Chris Nye');
  const nonce: bigint = encodeStringToBigInt('5678');
  const age: bigint = BigNumber.from(20) as unknown as bigint;
  const country: bigint = encodeStringToBigInt('BR');
  const commits = [name, age, country].map((v) =>
    createPoseidonHash(poseidon, [v, nonce]).toString(),
  );
  const merkleProof = await generateMerkleProof('BR');
  const witness = {
    values: [name, age, country].map((v) => v.toString()),
    nonces: [nonce.toString(), nonce.toString(), nonce.toString()],
    commits,
    age: 18,
    ...merkleProof,
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
  const input = publicSignals.map((signal) =>
    BigNumber.from(signal).toHexString(),
  );
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
