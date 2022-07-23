// Referenced from https://github.com/appliedzkp/semaphore/blob/main/scripts/compile-circuits.ts

import fs from 'fs';
import { zKey } from 'snarkjs';
import logger from 'js-logger';
import util from 'node:util';
const exec = util.promisify(require('child_process').exec);

async function main() {
  const buildPath = './circuit';
  const solidityVersion = '0.8.13';

  if (!fs.existsSync(buildPath)) {
    fs.mkdirSync(buildPath, { recursive: true });
  }
  console.log('Compile circuit');
  const { stdout, stderr } = await exec(
    `circom ./circuit/verifytalent.circom --r1cs --wasm -o ${buildPath}`,
  );
  if (stderr) {
    throw new Error(stderr);
  }
  if (stdout) {
    console.log('Compile circuit done', { stdout });
  }

  // Generate zkey from ptau(first contribution, second contribution)
  await zKey.newZKey(
    `${buildPath}/verifytalent.r1cs`,
    `${buildPath}/powersOfTau28_hez_final_10.ptau`,
    `${buildPath}/verifytalent_0000.zkey`,
    logger,
  );

  // Apply random beacon
  await zKey.beacon(
    `${buildPath}/verifytalent_0000.zkey`,
    `${buildPath}/verifytalent_final.zkey`,
    'Final Beacon',
    '0102030405060708090a0b0c0d0e0f202122232425262728292a2b2c2d2e2f',
    10,
    logger,
  );

  // Export verifier code
  let verifierCode = (await zKey.exportSolidityVerifier(
    `${buildPath}/verifytalent_final.zkey`,
    {
      groth16: fs.readFileSync(
        './node_modules/snarkjs/templates/verifier_groth16.sol.ejs',
        'utf8',
      ),
    },
    logger,
  )) as string;

  // Replace solidity version
  verifierCode = verifierCode.replace(
    /pragma solidity \^\d+\.\d+\.\d+/,
    `pragma solidity ^${solidityVersion}`,
  );

  fs.writeFileSync('./src/TalentVerifier.sol', verifierCode, 'utf-8');

  // Verification key to use on the client side for generating proofs
  const verificationKey = await zKey.exportVerificationKey(
    `${buildPath}/verifytalent_final.zkey`,
    logger,
  );
  fs.writeFileSync(
    `${buildPath}/verification_key.json`,
    JSON.stringify(verificationKey),
    'utf-8',
  );

  fs.renameSync(
    `${buildPath}/verifytalent_js/verifytalent.wasm`,
    `${buildPath}/verifytalent.wasm`,
  );
  // We will not remove them
  // rimraf.sync(`${buildPath}/verifytalent_js`);
  // rimraf.sync(`${buildPath}/powersOfTau28_hez_final_16.ptau`);
  // rimraf.sync(`${buildPath}/verifytalent_0000.zkey`);
  // rimraf.sync(`${buildPath}/verifytalent.r1cs`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
