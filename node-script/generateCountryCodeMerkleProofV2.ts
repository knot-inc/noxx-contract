import path from 'path';
import { generateMerkleProof } from './utils/generateMerkleProofV2';

async function main() {
  const countryCode = process.argv[2];
  console.log('GenerateMerkleProof for ', countryCode);
  const filepath = path.join('./node-script', 'tree.json');
  return generateMerkleProof(filepath, countryCode);
}

main()
  .then(() => (process.exitCode = 0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
