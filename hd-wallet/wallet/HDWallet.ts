// frontend/src/wallet.ts
import { ethers } from "ethers";

// Define the wallet type
interface Wallet {
  address: string;
  privateKey: string;
  path: string;
}

// Function to create an HD wallet
export function createHDWallet(numAddresses: number = 3): {
  mnemonic: string;
  wallets: Wallet[];
} {
  // Generate a random mnemonic (128-bit entropy = 12 words)
  const mnemonic = ethers.utils.entropyToMnemonic(ethers.utils.randomBytes(16));

  // Create an HD wallet node from the mnemonic
  const hdNode = ethers.utils.HDNode.fromMnemonic(mnemonic);

  // Derive multiple wallets using Ethereum's BIP-44 path: m/44'/60'/0'/0/index
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

// Test the function
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
