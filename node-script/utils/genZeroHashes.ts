import { MERKLE_TREE_DEPTH } from '../config.js';
import { createPoseidonHash } from '../zk-tools/lib/index.js';

export const genZeroHashes = (poseidon: any) => {
  let zeroHash = 0n;
  // Generate zero hashes for insertion padding
  const zeroes: bigint[] = [];
  for (let level = 0; level < MERKLE_TREE_DEPTH; level++) {
    zeroHash =
      level === 0
        ? zeroHash
        : createPoseidonHash(poseidon, [zeroHash, zeroHash]);
    zeroes.push(zeroHash);
  }
  return zeroes;
};
