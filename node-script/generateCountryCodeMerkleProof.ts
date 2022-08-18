import { generateMerkleProof } from './utils/generateMerkleProof';

async function main() {
  const countryCode = process.argv[2];
  console.log('GenerateMerkleProof for ', countryCode);
  return generateMerkleProof(countryCode);
}

main()
  .then(() => (process.exitCode = 0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
