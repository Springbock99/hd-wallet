// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SimpleWallet} from "./SimpleWallet.sol";

contract SimpleWalletFactory {
    mapping(address => address) public wallets;

    function deployWallet(bytes32 salt) external returns (address) {
        SimpleWallet wallet = new SimpleWallet{salt: salt}(msg.sender);
        address walletAddr = address(wallet);

        // Store the wallet address for the caller
        wallets[msg.sender] = walletAddr;

        return walletAddr;
    }

    function getWalletAddress(
        bytes32 salt,
        address walletOwner
    ) external view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(SimpleWallet).creationCode,
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
