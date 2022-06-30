import { task, types } from "hardhat/config";
import { ContractName, DeployedContract } from "./types";
import { readFileSync, writeFileSync } from "fs";
import { execSync } from "child_process";
import { join } from "path";

task(
  "update-configs",
  "Write the deployed addresses to the SDK and subgraph configs"
)
  .addParam(
    "contracts",
    "Contract objects from the deployment",
    undefined,
    types.json
  )
  .setAction(
    async (
      { contracts }: { contracts: Record<ContractName, DeployedContract> },
      { ethers }
    ) => {
      const { name: network, chainId } = await ethers.provider.getNetwork();

      // Update SDK addresses
      const sdkPath = join(__dirname, "../../myths-sdk");
      const addressesPath = join(sdkPath, "src/contract/addresses.json");
      const addresses = JSON.parse(readFileSync(addressesPath, "utf8"));
      addresses[chainId] = {
        mythsToken: contracts.MythsToken.address,
        mythsSeeder: contracts.MythsSeeder.address,
        mythsDescriptor: contracts.MythsDescriptor.address,
        nftDescriptor: contracts.NFTDescriptor.address,
        mythsAuctionHouse: contracts.MythsAuctionHouse.address,
        mythsAuctionHouseProxy: contracts.MythsAuctionHouseProxy.address,
        mythsAuctionHouseProxyAdmin:
          contracts.MythsAuctionHouseProxyAdmin.address,
        mythsDaoExecutor: contracts.MythsDAOExecutor.address,
        mythsDAOProxy: contracts.MythsDAOProxy.address,
        mythsDAOLogicV1: contracts.MythsDAOLogicV1.address,
      };
      writeFileSync(addressesPath, JSON.stringify(addresses, null, 2));
      try {
        execSync("yarn build", {
          cwd: sdkPath,
        });
      } catch {
        console.log(
          "Failed to re-build `@myths/sdk`. Please rebuild manually."
        );
      }
      console.log("Addresses written to the Myths SDK.");

      // Generate subgraph config
      const configName = `${network}-fork`;
      const subgraphConfigPath = join(
        __dirname,
        `../../myths-subgraph/config/${configName}.json`
      );
      const subgraphConfig = {
        network,
        mythsToken: {
          address: contracts.MythsToken.address,
          startBlock:
            contracts.MythsToken.instance.deployTransaction.blockNumber,
        },
        mythsAuctionHouse: {
          address: contracts.MythsAuctionHouseProxy.address,
          startBlock:
            contracts.MythsAuctionHouseProxy.instance.deployTransaction
              .blockNumber,
        },
        mythsDAO: {
          address: contracts.MythsDAOProxy.address,
          startBlock:
            contracts.MythsDAOProxy.instance.deployTransaction.blockNumber,
        },
      };
      writeFileSync(
        subgraphConfigPath,
        JSON.stringify(subgraphConfig, null, 2)
      );
      console.log("Subgraph config has been generated.");
    }
  );
