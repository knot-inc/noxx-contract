import { BigNumberish } from 'ethers';

export type TreeNode = {
  countryCode?: string | null;
  dataType: string;
  hash: BigNumberish;
  id: string;
  index: number;
  level: number;
  parent?: TreeNode | null;
  siblinghash?: BigNumberish | null;
  createdAt: string;
};
