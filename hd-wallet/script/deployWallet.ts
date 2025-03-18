import { ethers } from "ethers";
import { createHDWallet } from "./wallet.js";
import * as fs from "fs";
import * as dotenv from "dotenv";
dotenv.config();

const FACTORY_ABI =  ;
const alchemyUrl = process.env.ALCHEMY_API;

async function main() {
  let hdWalletData;
  try{
     hdWalletData = hdWalletData = JSON.parse(fs.readFileSync("./hdwallet.json", "utf8"));
     console.log("Loaded existing HD wallet from file");
  } catch (error) {
    hdWalletData = createHDWallet(5); 
    fs.writeFileSync("./hdwallet.json", JSON.stringify(hdWalletData, null, 2));
    console.log("Created new HD wallet and saved to file");
  }

  const provider = new ethers.providers.AlchemyProvider(alchemyUrl)

  const signer =  new ethers.Wallet(hdWalletData.wallets[0].privateKey, provider);
  console.log(`Using Wallet address: ${signer.address}`);

  const factoryAddress = ;



} 