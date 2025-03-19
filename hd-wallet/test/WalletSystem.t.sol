// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/Beacon.sol";
import "../contracts/WalletProxy.sol";
import "../contracts/WalletFactory.sol";
import "../contracts/ImplementationWallet.sol";

contract WalletSystemTest is Test {
    ImplementationWallet implementation;
    Beacon beacon;
    WalletFactory factory;

    address deployer = address(this);
    address user1 = address(0xBEEF);
    bytes32 salt = keccak256("test-wallet");

    function setUp() public {
        // Deploy implementation
        implementation = new ImplementationWallet();

        // Deploy beacon with the implementation
        beacon = new Beacon(address(implementation));

        // Deploy factory with beacon address
        factory = new WalletFactory(address(beacon));
    }

    function test_DeployWalletViaFactory() public {
        vm.prank(user1);
        address walletAddr = factory.deployWallet(salt);

        assertEq(factory.wallets(user1, salt), walletAddr);

        address impl = factory.getImplementation();
        assertEq(impl, address(implementation));
    }

    function test_WalletProxyDelegatesToImplementation() public {
        vm.prank(user1);
        address walletAddr = factory.deployWallet(salt);
        console.log("WalltAdrss of the factory contract:", walletAddr);

        // Send ETH to wallet
        vm.deal(deployer, 1 ether);
        payable(walletAddr).transfer(1 ether);

        // Call getBalance() via proxy
        uint256 balance = ImplementationWallet(payable(walletAddr))
            .getBalance();
        assertEq(balance, 1 ether);
    }
}
