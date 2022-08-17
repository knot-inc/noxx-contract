import path from 'path';
import fs from 'fs';
import {
  buildPoseidon,
  createPoseidonHash,
  encodeStringToBigInt,
} from './zk-tools/lib';
import { appendLeaf } from './db/dbUtils';
import { MERKLE_TREE_DEPTH, TableName } from './config';
import { genZeroHashes } from './utils/genZeroHashes';

/**
 * Seeding country code hashes for each level.
 * Data structure:
 *   id: CountryCodeTree_{level}_{id}
 *   dataType: CountryCode_Hash
 *   dataValue: {hash}
 *   hash
 *   level
 *   siblinghash
 *   parent
 *   createdAt
 */
async function main() {
  if (!TableName) throw new Error('No table name');

  console.log('Seeding zero hashes to: ', TableName);
  const poseidon = await buildPoseidon();

  // Generate zero hashes for insertion padding
  const zeroes: bigint[] = genZeroHashes(poseidon);

  try {
    // insert from file
    const filePath = path.join(__dirname, 'country.csv');
    const data = fs.readFileSync(filePath, 'utf-8');
    const lines = data.split(/\r?\n/);
    const regex = /\"(.+),(.+)\"/;
    // start appending to DB
    for (let index = 0; index < lines.length; index++) {
      const line = lines[index];
      const simplified = line.replace(regex, '$1'); // "Saint Helena, Ascension and Tristan da Cunha" => "SaintHelena"
      const arr = simplified.split(',');
      console.log('Inserting ', arr[0]);
      // encode ISO Country code
      const hash = createPoseidonHash(poseidon, [encodeStringToBigInt(arr[1])]);
      await appendLeaf({
        depth: MERKLE_TREE_DEPTH,
        hash,
        index,
        poseidon,
        TableName,
        zeroes,
      });
    }
  } catch (error) {
    console.log(error);
  }
}

main()
  .then(() => (process.exitCode = 0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
