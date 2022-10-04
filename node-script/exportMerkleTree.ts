import path from 'path';
import fs from 'fs';
import { TableName } from './config';
import { nodesQuery } from './db/dbUtils';

export const exportMerkleTree = async () => {
  if (!TableName) {
    throw new Error('No table');
  }
  console.log('Table: ', TableName);
  const nodes = await nodesQuery({ TableName });

  const outPath = path.join('./node-script', 'tree.json');
  let fd: number = 0;
  try {
    if (fs.existsSync(outPath)) {
      fs.rmSync(outPath);
    }
    fd = fs.openSync(outPath, 'w');
    fs.writeSync(fd, Buffer.from(JSON.stringify(nodes)));
  } catch (err) {
    console.error(err);
  } finally {
    fs.closeSync(fd);
  }

  return;
};

exportMerkleTree()
  .then()
  .catch((e) => console.log(e));
