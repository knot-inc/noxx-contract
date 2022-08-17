import { createPoseidonHash } from '../zk-tools/lib';
import { TreeNode } from '../types/node';
import {
  TransactWriteCommandInput,
  TransactWriteCommand,
  GetCommand,
  UpdateCommandInput,
  PutCommandInput,
  PutCommand,
  GetCommandInput,
  TransactGetCommandInput,
  TransactGetCommand,
  TransactGetCommandOutput,
  QueryCommand,
} from '@aws-sdk/lib-dynamodb';
import { ddbDocClient } from './dbclient';
import { BigNumberish } from 'ethers';

export const getTx = ({
  id,
  TableName,
}: {
  id: string;
  TableName: string;
}): { Get: GetCommandInput } => {
  return {
    Get: {
      Key: { id, dataType: 'CountryCode' },
      TableName,
    },
  };
};

const createTx = ({
  Item,
  TableName,
}: {
  Item: any;
  TableName: string;
}): { Put: PutCommandInput } => {
  return {
    Put: {
      Item,
      TableName,
    },
  };
};

const updateTx = ({
  Key,
  TableName,
  props,
}: {
  Key: Record<string, string>;
  TableName: string;
  props: {
    UpdateExpression: string;
    ExpressionAttributeNames: { [key: string]: string };
    ExpressionAttributeValues: { [key: string]: any };
  };
}): { Update: UpdateCommandInput } => {
  return {
    Update: {
      ...props,
      Key,
      TableName,
    },
  };
};

export const batchWriteTx = async (TransactItems: any[]) => {
  const input: TransactWriteCommandInput = {
    TransactItems,
  };
  return await ddbDocClient.send(new TransactWriteCommand(input));
};

export const batchReadTx = async (
  TransactItems: any[],
): Promise<TransactGetCommandOutput> => {
  const input: TransactGetCommandInput = {
    TransactItems,
  };
  return await ddbDocClient.send(new TransactGetCommand(input));
};

const nodeCreate = async ({
  Item,
  TableName,
}: {
  Item: any;
  TableName: string;
}) => {
  await ddbDocClient.send(
    new PutCommand({
      Item,
      TableName,
    }),
  );
};

export const nodeGet = async ({
  level,
  index,
  TableName,
}: {
  level: number;
  index: number;
  TableName: string;
}): Promise<TreeNode> => {
  const result = await ddbDocClient.send(
    new GetCommand({
      Key: {
        id: `CountryCodeTree_${level}_${index}`,
        dataType: 'CountryCode',
      },
      TableName,
    }),
  );
  return result.Item as TreeNode;
};

export const nodeGetByHash = async ({
  hash,
  TableName,
}: {
  hash: BigNumberish;
  TableName: string;
}): Promise<TreeNode> => {
  console.log({ hash });
  const value = await ddbDocClient.send(
    new QueryCommand({
      IndexName: 'dataType-dataValue',
      KeyConditionExpression: 'dataType = :t and dataValue = :v',
      ExpressionAttributeValues: {
        ':t': 'CountryCode_Hash',
        ':v': hash,
      },
      TableName,
    }),
  );

  if (!value.Items?.length) {
    throw new Error('No item');
  }
  const id = value.Items[0].id;

  const result = await ddbDocClient.send(
    new GetCommand({
      Key: { id, dataType: 'CountryCode' },
      TableName,
    }),
  );
  return result.Item as TreeNode;
};

export const nodesQuery = async ({
  TableName,
}: {
  TableName: string;
}): Promise<TreeNode[]> => {
  const value = await ddbDocClient.send(
    new QueryCommand({
      IndexName: 'dataType-id',
      KeyConditionExpression: 'dataType = :t',
      ExpressionAttributeValues: {
        ':t': 'CountryCode',
      },
      TableName,
    }),
  );
  return value.Items as TreeNode[];
};

export const appendLeaf = async ({
  depth,
  index,
  hash,
  TableName,
  poseidon,
  zeroes,
}: {
  depth: number;
  index: number;
  hash: BigNumberish;
  TableName: string;
  poseidon: any;
  zeroes: any[];
}) => {
  let currentIndex = index;
  // internal id should be easy to query by level and index
  let node: TreeNode = {
    hash,
    id: `CountryCodeTree_0_${index}`,
    dataType: 'CountryCode',
    index,
    level: 0,
    siblinghash: null,
    parent: null,
    createdAt: new Date().toISOString(),
  };

  await nodeCreate({
    Item: node,
    TableName,
  });
  // For Querying with hash, just for leaves
  await nodeCreate({
    Item: {
      hash,
      id: `CountryCodeTree_0_${index}`,
      dataType: 'CountryCode_Hash',
      dataValue: hash,
    },
    TableName,
  });

  for (let level = 0; level < depth; level++) {
    const tx: any[] = [];
    if (currentIndex % 2 === 0) {
      node.siblinghash = zeroes[level];
      let parentNode: TreeNode | undefined;
      try {
        parentNode = await nodeGet({
          level: level + 1,
          index: Math.floor(currentIndex / 2),
          TableName,
        });
      } catch {}

      if (parentNode) {
        parentNode.hash = createPoseidonHash(poseidon, [
          node.hash as string,
          node?.siblinghash as string,
        ]);

        tx.push(
          updateTx({
            Key: { id: parentNode.id, dataType: 'CountryCode' },
            TableName,
            props: {
              UpdateExpression: 'set #h=:h',
              ExpressionAttributeNames: { '#h': 'hash' },
              ExpressionAttributeValues: { ':h': parentNode.hash },
            },
          }),
        );
      } else {
        const parentLevel = level + 1;
        const parentIndex = Math.floor(currentIndex / 2);
        const parentHash = createPoseidonHash(poseidon, [
          node.hash as string,
          node?.siblinghash as string,
        ]);
        parentNode = {
          dataType: 'CountryCode',
          hash: parentHash,
          id: `CountryCodeTree_${parentLevel}_${parentIndex}`,
          index: parentIndex,
          level: parentLevel,
          siblinghash: null,
          parent: null,
          createdAt: new Date().toISOString(),
        };
        tx.push(
          createTx({
            Item: parentNode,
            TableName,
          }),
        );
      }
      tx.push(
        updateTx({
          Key: { id: node.id, dataType: 'CountryCode' },
          TableName,
          props: {
            UpdateExpression: 'set #p=:p',
            ExpressionAttributeNames: { '#p': 'parent' },
            ExpressionAttributeValues: { ':p': parentNode },
          },
        }),
      );

      node = parentNode;
    } else {
      const siblingNode = await nodeGet({
        level,
        index: currentIndex - 1,
        TableName,
      });

      node.siblinghash = siblingNode.hash;

      const parentNode = await nodeGet({
        level: level + 1,
        index: Math.floor(currentIndex / 2),
        TableName,
      });

      const newParentNode = {
        ...parentNode,
        hash: createPoseidonHash(poseidon, [
          siblingNode.hash as string,
          node.hash as string,
        ]),
      };

      node.parent = newParentNode;

      tx.push(
        ...[
          // update node
          updateTx({
            Key: { id: node.id, dataType: 'CountryCode' },
            TableName,
            props: {
              UpdateExpression: 'set #p=:p, #s=:s',
              ExpressionAttributeNames: {
                '#p': 'parent',
                '#s': 'siblinghash',
              },
              ExpressionAttributeValues: {
                ':p': newParentNode,
                ':s': siblingNode.hash,
              },
            },
          }),
          // update sibling
          updateTx({
            Key: { id: siblingNode.id, dataType: 'CountryCode' },
            TableName,
            props: {
              UpdateExpression: 'set #p=:p, #s=:s',
              ExpressionAttributeNames: {
                '#p': 'parent',
                '#s': 'siblinghash',
              },
              ExpressionAttributeValues: {
                ':p': newParentNode,
                ':s': node.hash,
              },
            },
          }),
          // update parent
          updateTx({
            Key: { id: parentNode.id, dataType: 'CountryCode' },
            TableName,
            props: {
              UpdateExpression: 'set #h=:h',
              ExpressionAttributeNames: { '#h': 'hash' },
              ExpressionAttributeValues: {
                ':h': newParentNode.hash,
              },
            },
          }),
        ],
      );

      node = newParentNode;
    }

    await batchWriteTx(tx);
    currentIndex = Math.floor(currentIndex / 2);
  }
};
