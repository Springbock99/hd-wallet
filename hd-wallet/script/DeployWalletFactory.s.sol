// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Script.sol";
// import "../contracts/ImplementationWallet.sol";
// import "../contracts/Beacon.sol";
// import "../contracts/WalletProxy.sol";
// import "../contracts/WalletFactory.sol";

// contract DeployWalletFactoryScript is Script {
//     function run() external {
//         // Load private key from environment
//         string memory privateKey = vm.envString("PRIVATE_KEY");
//         address deployer = vm.rememberKey(vm.parseUint(privateKey));

//         vm.startBroadcast(deployer);

//         // Deploy WalletImplementation
//         ImplementationWallet impl = new ImplementationWallet();
//         console.log("WalletImplementation deployed at:", address(impl));

//         // Deploy Beacon with WalletImplementation
//         Beacon beacon = new Beacon(address(impl));
//         console.log("Beacon deployed at:", address(beacon));

//         // Deploy WalletFactory with Beacon
//         WalletFactory factory = new WalletFactory(address(beacon));
//         console.log("WalletFactory deployed at:", address(factory));

//         vm.stopBroadcast();
//     }
// }
