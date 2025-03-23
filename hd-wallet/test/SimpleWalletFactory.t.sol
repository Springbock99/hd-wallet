// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, Vm, console} from "forge-std/Test.sol";
import {SimpleWallet} from "../contracts/SimpleWallet.sol";
import {SimpleWalletFactory} from "../contracts/SimpleWalletFactory.sol";

contract SimpleWalletFactoryTest is Test {
    SimpleWalletFactory public factory;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        factory = new SimpleWalletFactory();
    }

    function test_WalletDeployment() public {
        bytes32 salt = keccak256(abi.encodePacked("test-salt"));

        address predictedAddress = factory.getWalletAddress(salt, user1);

        vm.prank(user1);
        address deployedAddress = factory.deployWallet(salt);

        address storedAddress = factory.wallets(user1);

        assertEq(
            deployedAddress,
            predictedAddress,
            "Deployed address should match predicted"
        );
        assertEq(
            storedAddress,
            predictedAddress,
            "Stored address should match predicted"
        );

        SimpleWallet wallet = SimpleWallet(payable(deployedAddress));
        assertEq(wallet.owner(), user1, "Wallet Owner should be user1");
    }

    function test_DeterministicAddresses() public {
        bytes32 salt = keccak256(abi.encodePacked("deterministic-salt"));

        address predictedAddress1 = factory.getWalletAddress(salt, user1);
        address predictedAddress2 = factory.getWalletAddress(salt, user1);

        assertEq(
            predictedAddress1,
            predictedAddress2,
            "Address calculation should be deterministic"
        );

        vm.roll(block.number + 100);
        vm.warp(block.timestamp + 3600);

        address predictedAddress3 = factory.getWalletAddress(salt, user1);

        assertEq(
            predictedAddress1,
            predictedAddress3,
            "Address should be independent of blockchain state"
        );
    }
}
