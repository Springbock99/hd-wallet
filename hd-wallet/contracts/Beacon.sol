// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {WalletProxy} from "./WalletProxy.sol";

contract Beacon {
    address public immutable implementation;

    // Maps owner address to wallet address
    mapping(address => address) public wallets;

    event WalletCreated(address indexed owner, address walletAddress);

    constructor(address _implementation) {
        require(_implementation != address(0), "Invalid Implemetation address");
        implementation = _implementation;
    }

    function getImplementation() external view returns (address) {
        return implementation;
    }
    /**
     * @dev Deploys a new wallet proxy for the sender.
     * @param salt A unique value to generate a deterministic address
     * @return The address of the newly created wallet
     */
    function deployWallet(bytes32 salt) external returns (address) {
        // Create new wallet proxy with CREATE2 for deterministic addresses
        WalletProxy wallet = new WalletProxy{salt: salt}(
            address(this),
            msg.sender
        );
        address walletAddr = address(wallet);

        // Store the wallet address
        wallets[msg.sender] = walletAddr;

        // Emit event
        emit WalletCreated(msg.sender, walletAddr);

        return walletAddr;
    }

    /**
     * @dev Computes the address of a wallet that would be created using deployWallet.
     * @param salt The salt used for address generation
     * @param walletOwner The owner of the wallet
     * @return The computed address
     */
    function getWalletAddress(
        bytes32 salt,
        address walletOwner
    ) external view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(WalletProxy).creationCode,
            abi.encode(walletOwner)
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
}
