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

export function restoreHDWallet(
  mnemonic: string,
  numAddresses: number = 3
): {
  wallets: Wallet[];
} {
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

  return { wallets };
}

export async function deploySmartWallet(
  mnemonic: string,
  hdIndex: number,
  provider: ethers.providers.Provider,
  factoryAddress: string
): Promise<string> {
  const hdNode = ethers.utils.HDNode.fromMnemonic(mnemonic);
  const path = `m/44'/60'/0'/0/${hdIndex}`;
  const wallet = hdNode.derivePath(path);

  const signer = new ethers.Wallet(wallet.privateKey, provider);

  const factory = new ethers.Contract(
    factoryAddress,
    ["function deployWallet(bytes32 salt) external returns (address)"],
    signer
  );

  const salt = ethers.utils.keccak256(
    ethers.utils.defaultAbiCoder.encode(["string", "uint256"], [path, hdIndex])
  );

  const tx = await factory.deployWallet(salt);
  const receipt = await tx.wait();

  const event = receipt.events?.find(
    (e: ethers.Event) => e.event === "WalletCreated"
  );

  if (!event || !event.args) {
    throw new Error(
      "Failed to deploy wallet: Event not found or missing arguments"
    );
  }

  return event.args.walletAddress;
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
