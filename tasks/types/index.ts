import { Contract } from "ethers";

export enum ChainId {
  Mainnet = 1,
  Ropsten = 3,
  Rinkeby = 4,
  Kovan = 42,
}

// prettier-ignore
export type ContractName = 'NFTDescriptor' | 'MythsDescriptor' | 'MythsSeeder' | 'MythsToken' | 'MythsAuctionHouse' | 'MythsAuctionHouseProxyAdmin' | 'MythsAuctionHouseProxy' | 'MythsDAOExecutor' | 'MythsDAOLogicV1' | 'MythsDAOProxy';

export interface ContractDeployment {
  args?: (string | number | (() => string))[];
  libraries?: () => Record<string, string>;
  waitForConfirmation?: boolean;
  validateDeployment?: () => void;
}

export interface DeployedContract {
  name: string;
  address: string;
  instance: Contract;
  constructorArguments: (string | number)[];
  libraries: Record<string, string>;
}
