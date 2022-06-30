import { Result } from "ethers/lib/utils";
import { task, types } from "hardhat/config";

task("mint-myth", "Mints a Myth")
  .addOptionalParam(
    "mythsToken",
    "The `MythsToken` contract address",
    //TODO:REPLACE
    "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
    types.string
  )
  .setAction(async ({ mythsToken }, { ethers }) => {
    const nftFactory = await ethers.getContractFactory("MythsToken");
    const nftContract = nftFactory.attach(mythsToken);

    const receipt = await (await nftContract.mint()).wait();
    const mythCreated = receipt.events?.[1];
    const { tokenId } = mythCreated?.args as Result;

    console.log(`Myth minted with ID: ${tokenId.toString()}.`);
  });
