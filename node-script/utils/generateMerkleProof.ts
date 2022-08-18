import { genZeroHashes } from './genZeroHashes';
import { MERKLE_TREE_DEPTH, TableName } from '../config';
import {
  buildPoseidon,
  createPoseidonHash,
  encodeStringToBigInt,
} from '../zk-tools/lib';
import {
  batchReadTx,
  getTx,
  nodeGet,
  nodeGetByHash,
  nodesQuery,
} from '../db/dbUtils';
import { TreeNode } from '../types/node';
import { BigNumberish } from 'ethers';

export const generateMerkleProof = async (countryCode: string) => {
  if (!TableName) {
    throw new Error('No table');
  }
  console.log('Table: ', TableName);

  const ccTobigint = encodeStringToBigInt(countryCode);
  console.log({ ccTobigint });
  const poseidon = await buildPoseidon();
  // Check the index of identityCommitment
  const zeroes = genZeroHashes(poseidon);
  const hash = createPoseidonHash(poseidon, [
    encodeStringToBigInt(countryCode),
  ]);
  const leafNode = await nodeGetByHash({ hash, TableName });
  const nodes = await nodesQuery({ TableName });
  const root = await nodeGet({
    level: MERKLE_TREE_DEPTH,
    index: 0,
    TableName,
  });
  let index = leafNode.index;

  const tx: any[] = [];
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
          tx.push(
            getTx({
              id: `CountryCodeTree_${level}_${i}`,
              TableName,
            }),
          );
        } else {
          const zeroHash = zeroes[level];
          siblings[level] = zeroHash;
        }
      }
    }

    index = Math.floor(index / 2);
  }

  if (tx.length) {
    const r = await batchReadTx(tx);
    r.Responses?.forEach((response) => {
      const node = response.Item as TreeNode;
      siblings[node.level] = node.hash.toString();
    });
  }
  const merkleProof = {
    leaf: leafNode.hash.toString(),
    root: root.hash.toString(),
    pathIndices,
    siblings,
  };
  console.log(merkleProof);
  return merkleProof;
};
