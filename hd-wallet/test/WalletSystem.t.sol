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

    function testDeployWalletViaFactory() public {
        // Deploy wallet for user1
        vm.prank(user1);
        address walletAddr = factory.deployWallet(salt);

        // Verify it was stored
        assertEq(factory.wallets(user1, salt), walletAddr);

        // Verify the implementation address from the beacon
        address impl = factory.getImplementation();
        assertEq(impl, address(implementation));
    }
}
