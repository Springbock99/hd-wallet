// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {WalletProxy} from "./WalletProxy.sol";
import {Beacon} from "./Beacon.sol";

contract WalletFactory {
    address public immutable beacon;

    // Map from owner address to salt to wallet address
    mapping(address => mapping(bytes32 => address)) public wallets;

    // Array of wallets per owner for easy retrieval
    mapping(address => address[]) public userWallets;

    event WalletCreated(
        address indexed owner,
        address walletAddress,
        bytes32 salt
    );

    constructor(address _beacon) {
        beacon = _beacon;
    }

    /**
     * @dev Deploy a new wallet proxy with the caller as owner
     * @param salt Unique salt for CREATE2 deterministic address
     * @return walletAddr The address of the deployed wallet
     */
    function deployWallet(bytes32 salt) external returns (address) {
        // Check if wallet with this salt already exists for the sender
        require(
            wallets[msg.sender][salt] == address(0),
            "Wallet with this salt already exists"
        );

        WalletProxy wallet = new WalletProxy{salt: salt}(beacon, msg.sender);
        address walletAddr = address(wallet);

        wallets[msg.sender][salt] = walletAddr;
        userWallets[msg.sender].push(walletAddr);

        // Emit event
        emit WalletCreated(msg.sender, walletAddr, salt);

        return walletAddr;
    }

    function getWallet(
        address owner,
        bytes32 salt
    ) external view returns (address) {
        return wallets[owner][salt];
    }

    /**
     * @dev Predict the address of a wallet before deployment
     * @param salt The salt for CREATE2
     * @return The predicted address
     */
    function predictWalletAddress(
        bytes32 salt
    ) external view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(WalletProxy).creationCode,
            abi.encode(msg.sender)
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );

        return address(uint160(uint256(hash)));
    }

    /**
     * @dev Get all wallets owned by an address
     * @param owner The owner address
     * @return Array of wallet addresses
     */
    function getWalletsByOwner(
        address owner
    ) external view returns (address[] memory) {
        return userWallets[owner];
    }

    /**
     * @dev Get the current implementation address from the beacon
     * @return The implementation address
     */
    function getImplementation() external view returns (address) {
        return Beacon(beacon).implementation();
    }
}
