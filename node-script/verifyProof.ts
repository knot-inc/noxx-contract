import generateSolidityInputs from './generateSolidityInputsV2.js';

generateSolidityInputs()
  .then(() => {
    process.exitCode = 0;
  })
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
