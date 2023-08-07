import fs from 'fs';
import { fileURLToPath } from 'url';
import path, { dirname } from 'path';
import { utils } from 'ethers';
import {
  buildPoseidon,
  createPoseidonHash,
  encodeStringToBigInt,
} from './zk-tools/lib/index.js';
import { generateMerkleProof } from './utils/generateMerkleProofV2.js';
import {
  BarretenbergApiAsync,
  Crs,
  newBarretenbergApiAsync,
  RawBuffer,
} from '@aztec/bb.js/dest/node/index.js';
import { decompressSync } from 'fflate';
import circuit from '../circuit_v2/target/main.json' assert { type: 'json' };
import { executeCircuit, compressWitness } from '@noir-lang/acvm_js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const filepath = path.join('./node-script', 'tree.json');

async function generateWitness(
  input: Map<number, string>,
  acirBuffer: Buffer,
): Promise<Uint8Array> {
  const witnessMap = await executeCircuit(acirBuffer, input, () => {
    throw Error('unexpected oracle');
  });

  const witnessBuff = compressWitness(witnessMap);
  return witnessBuff;
}

async function generateProof(
  api: BarretenbergApiAsync,
  acirBuffer: Buffer,
  witness: Uint8Array,
) {
  const acirBufferUncompressed = decompressSync(acirBuffer);

  const [, total] = await api.acirGetCircuitSizes(acirBufferUncompressed);
  const subgroupSize = Math.pow(2, Math.ceil(Math.log2(total)));
  const crs = await Crs.new(subgroupSize + 1);
  await api.commonInitSlabAllocator(subgroupSize);
  await api.srsInitSrs(
    new RawBuffer(crs.getG1Data()),
    crs.numPoints,
    new RawBuffer(crs.getG2Data()),
  );

  const acirComposer = await api.acirNewAcirComposer(subgroupSize);
  const proof = await api.acirCreateProof(
    acirComposer,
    acirBufferUncompressed,
    decompressSync(witness),
    false,
  );
  return proof;
}

async function verifyProof(
  api: BarretenbergApiAsync,
  acirBuffer: Buffer,
  proof: Uint8Array,
) {
  const acirBufferUncompressed = decompressSync(acirBuffer);

  const [, total] = await api.acirGetCircuitSizes(acirBufferUncompressed);
  const subgroupSize = Math.pow(2, Math.ceil(Math.log2(total)));
  const crs = await Crs.new(subgroupSize + 1);
  await api.commonInitSlabAllocator(subgroupSize);
  await api.srsInitSrs(
    new RawBuffer(crs.getG1Data()),
    crs.numPoints,
    new RawBuffer(crs.getG2Data()),
  );

  const acirComposer = await api.acirNewAcirComposer(subgroupSize);
  await api.acirInitProvingKey(acirComposer, acirBufferUncompressed);
  const verified = await api.acirVerifyProof(acirComposer, proof, false);
  return verified;
}

// Generate Solidity inputs for testing purpose
export default async function main() {
  console.log('Instantiating...');

  const api = await newBarretenbergApiAsync(4);
  const acirBuffer = Buffer.from(circuit.bytecode, 'base64');

  console.log('Generating inputs...');
  const poseidon = await buildPoseidon();
  const name: bigint = encodeStringToBigInt('Chris Nye');
  const nonce: bigint = encodeStringToBigInt('5678');
  const age: bigint = 20n;
  const country: bigint = encodeStringToBigInt('BR');
  const commits = [name, age, country].map((v) =>
    createPoseidonHash(poseidon, [v, nonce]),
  );
  const merkleProof = await generateMerkleProof(filepath, 'BR');

  console.log('Generating witness...');

  const witnessInputs = [
    commits,
    18n,
    [name, age, country],
    [nonce, nonce, nonce],
    merkleProof?.leaf,
    merkleProof?.root,
    merkleProof?.pathIndices,
    merkleProof?.siblings,
  ]
    .flatMap((v) => v)
    .reduce((acc: Map<number, string>, v, i) => {
      console.log(`witness input ${i}:`, v);
      // poseidon hash is a string of bignumber
      if (typeof v === 'string') {
        const hex = BigInt(v).toString(16);
        acc.set(i + 1, utils.hexZeroPad(`0x${hex}`, 32));
        return acc;
      }
      acc.set(i + 1, utils.hexZeroPad(`0x${v.toString(16)}`, 32));
      return acc;
    }, new Map<number, string>());

  console.log('witness inputs:', witnessInputs);

  const witness = await generateWitness(witnessInputs, acirBuffer);

  console.log('Generating proof...');

  const proof = await generateProof(api, acirBuffer, witness);

  console.log('proof', proof);
  console.log('Verify proof...');
  const verified = await verifyProof(api, acirBuffer, proof);
  console.log('Verified:', verified);

  // write to file
  const inputPath = path.join(__dirname, 'input.txt');
  if (fs.existsSync(inputPath)) {
    fs.unlinkSync(inputPath);
  }
  fs.openSync(inputPath, 'w');

  const publicInputs = proof.slice(0, 32 * 4);
  const slicedProof = proof.slice(32 * 4);
  fs.writeFileSync(
    inputPath,
    JSON.stringify({
      proof: Buffer.from(slicedProof).toString('hex'),
      inputs: Buffer.from(publicInputs).toString('hex'),
    }),
  );

  return { proof: slicedProof, publicInputs };
}
