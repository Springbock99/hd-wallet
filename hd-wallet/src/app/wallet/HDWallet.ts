import { ethers } from "ethers";

interface Wallet {
  address: string;
  privateKey: string;
  path: string;
}

export function createHDWallet(numAddresses: number = 3): {
  mnemonic: string;
  wallets: Wallet[];
} {
  const mnemonic = ethers.utils.entropyToMnemonic(ethers.utils.randomBytes(16));

  const hdNode = ethers.utils.HDNode.fromMnemonic(mnemonic);

  const wallets: Wallet[] = [];
  for (let i = 0; i < numAddresses; i++) {
    const path = `m/44'/60'/0'/0/${i}`;
    const wallet = hdNode.derivePath(path);
    wallets.push({
      address: wallet.address,
      privateKey: wallet.privateKey,
      path: path,
    });
  }

  return { mnemonic, wallets };
}

if (require.main === module) {
  const wallet = createHDWallet(3);
  console.log("Mnemonic:", wallet.mnemonic);
  console.log("Wallets:");
  wallet.wallets.forEach((w, index) => {
    console.log(`Wallet ${index + 1}:`);
    console.log(`  Path: ${w.path}`);
    console.log(`  Address: ${w.address}`);
    console.log(`  Private Key: ${w.privateKey}`);
  });
}
