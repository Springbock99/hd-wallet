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

        vm.deal(user1, 10 ether);
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

    function test_Withdraw() public {
        vm.prank(user1);
        address walletAdr = factory.deployWallet(salt);

        vm.deal(walletAdr, 2 ether);

        uint256 initialWalletBalance = address(walletAdr).balance;
        uint256 initialUserBalance = address(user1).balance;

        console.log("initial Wallet Balance:", initialWalletBalance);
        console.log("initial User Balance:", initialUserBalance);

        vm.prank(user1);
        ImplementationWallet(payable(walletAdr)).withdraw(1 ether);

        uint256 finalWalletBalance = address(walletAdr).balance;
        uint256 finalUserBalance = address(user1).balance;

        assertEq(finalWalletBalance, initialWalletBalance - 1 ether);
        assertEq(finalUserBalance, initialUserBalance + 1 ether);
    }

    function test_WithdrawWithWrongAddress() public {
        vm.prank(user1);
        address walletAddr = factory.deployWallet(salt);

        vm.deal(walletAddr, 2 ether);

        uint256 initialWalletBalance = address(walletAddr).balance;
        uint256 initialUserBalance = address(user1).balance;

        console.log("initial Wallet Balance:", initialWalletBalance);
        console.log("initial User Balance:", initialUserBalance);

        vm.prank(user1);
        ImplementationWallet(payable(walletAddr)).withdraw(1 ether);

        uint256 finalWalletBalance = address(walletAddr).balance;
        uint256 finalUserBalance = address(user1).balance;

        assertEq(finalWalletBalance, initialWalletBalance - 1 ether);
        assertEq(finalUserBalance, initialUserBalance + 1 ether);

        address nonOwner = address(0xCAFE);
        vm.startPrank(nonOwner);

        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );
        ImplementationWallet(payable(walletAddr)).withdraw(1 ether);

        vm.stopPrank();

        assertEq(
            address(walletAddr).balance,
            finalWalletBalance,
            "Wallet balance should not change after failed withdrawal"
        );
    }
}
