import path from 'path';
import fs from 'fs';
import { ethers } from 'ethers';
import { FormatTypes } from 'ethers/lib/utils.js';

const genHumanReadableABI = async ({
  contractFileName,
  contractName,
}: {
  contractFileName?: string;
  contractName?: string;
}) => {
  if (!contractName || !contractFileName) {
    return 'No contractName set';
  }

  const filePath = path.join(
    './out',
    `${contractFileName}.sol`,
    `${contractName}.json`,
  );

  const abistr = fs.readFileSync(filePath, 'utf8');
  const abi = JSON.parse(abistr).abi;

  const interfaceOfAbi = new ethers.utils.Interface(abi);
  const humanReadableFormat = interfaceOfAbi.format(
    FormatTypes.full,
  ) as string[];
  console.log({ humanReadableFormat });

  const outPath = `./abi/${contractFileName}.json`;
  try {
    if (fs.existsSync(outPath)) {
      fs.rmSync(outPath);
    }
    fs.appendFileSync(outPath, '[\n');
    const lastIndex = humanReadableFormat.length - 1;
    humanReadableFormat.forEach((str, i) => {
      if (i != lastIndex) {
        fs.appendFileSync(outPath, `"${str}",\n`);
      } else {
        fs.appendFileSync(outPath, `"${str}"\n`);
      }
    });
    fs.appendFileSync(outPath, ']\n');
    // file written successfully
  } catch (err) {
    console.error(err);
  }

  return;
};
console.log(`Generate Human readable abi from ${process.argv[2]}`);

genHumanReadableABI({
  contractFileName: process.argv[2],
  contractName: process.argv[3],
}).then(() => {
  console.log('Done');
});
