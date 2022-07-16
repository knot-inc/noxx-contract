import path from "path";
import fs from "fs";
import { ethers } from "ethers";
import { FormatTypes } from "ethers/lib/utils";

const genHumanReadableABI = async ({
  contractName,
}: {
  contractName?: string;
}) => {
  if (!contractName) {
    return "No contractName set";
  }

  const filePath = path.join(
    "../out",
    `${contractName}.sol`,
    `${contractName}.json`
  );

  const abistr = fs.readFileSync(filePath, "utf8");
  const abi = JSON.parse(abistr).abi;

  const interfaceOfAbi = new ethers.utils.Interface(abi);
  const humanReadableFormat = interfaceOfAbi.format(
    FormatTypes.full
  ) as string[];
  console.log({ humanReadableFormat });

  const outPath = `out/${contractName}.json`;
  try {
    if (fs.existsSync(outPath)) {
      fs.rmSync(outPath);
    }
    fs.appendFileSync(outPath, "[\n");
    humanReadableFormat.forEach((str) =>
      fs.appendFileSync(outPath, `"${str}",\n`)
    );
    fs.appendFileSync(outPath, "]\n");
    // file written successfully
  } catch (err) {
    console.error(err);
  }

  return;
};
console.log(`Generate Human readable abi from ${process.argv[2]}`);

genHumanReadableABI({
  contractName: process.argv[2],
}).then(() => {
  console.log("Done");
});
