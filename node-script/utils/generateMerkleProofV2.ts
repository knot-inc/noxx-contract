import fs from 'fs';
import { genZeroHashes } from './genZeroHashes.js';
import { MERKLE_TREE_DEPTH } from '../config.js';
import { buildPoseidon, encodeStringToBigInt } from '../zk-tools/lib/index.js';
import { BigNumberish } from 'ethers';
import { TreeNode } from '../types/node.js';

export const generateMerkleProof = async (
  path: string,
  countryCode: string,
) => {
  let fd: number = 0;
  try {
    fd = fs.openSync(path, 'r');
    const ccTobigint = encodeStringToBigInt(countryCode);
    console.log({ ccTobigint });
    const poseidon = await buildPoseidon();
    // Check the index of identityCommitment
    const zeroes = genZeroHashes(poseidon);
    const str = fs.readFileSync(path, 'utf-8');
    const nodes = JSON.parse(str);
    const leafNode = nodes.filter(
      (node: TreeNode) => node.countryCode === countryCode,
    )[0];
    const root = nodes.filter(
      (node) => node.level === MERKLE_TREE_DEPTH && node.index === 0,
    )[0];
    let index = leafNode.index;

    const pathIndices: number[] = [];
    const siblings: BigNumberish[] = [];
    for (let level = 0; level < MERKLE_TREE_DEPTH; level += 1) {
      const position = index % 2;
      const levelStartIndex = index - position;
      const levelEndIndex = levelStartIndex + 2;

      pathIndices[level] = position;

      for (let i = levelStartIndex; i < levelEndIndex; i += 1) {
        if (i !== index) {
          const length = nodes.filter((node) => node.level === level).length;
          if (i < length) {
            const n = nodes.filter(
              (node) => node.id === `CountryCodeTree_${level}_${i}`,
            )[0];
            siblings[n.level] = n.hash;
          } else {
            const zeroHash = zeroes[level];
            siblings[level] = zeroHash;
          }
        }
      }

      index = Math.floor(index / 2);
    }

    const merkleProof = {
      leaf: leafNode.hash,
      root: root.hash,
      pathIndices,
      siblings,
    };
    console.log(merkleProof);
    return merkleProof;
  } catch (error) {
    console.log(error);
    return;
  } finally {
    fs.closeSync(fd);
  }
};
