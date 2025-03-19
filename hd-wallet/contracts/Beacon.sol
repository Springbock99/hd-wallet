// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@oppenzeppelin-contracts/access/Ownable.sol";

contract Beacon is Ownable {
    address private _implementation;

    event ImplementationChanged(
        address indexed previousImplementation,
        address indexed newImplementation
    );

    constructor(address initialImplementation) Ownable(msg.sender) {
        require(
            initialImplementation != address(0),
            "Invalid implementation address"
        );
        _implementation = initialImplementation;
    }

    function implementation() public view returns (address) {
        return _implementation;
    }

    function getImplementation() external view returns (address) {
        return implementation();
    }

    function updateImplementation(
        address newImplementation
    ) external onlyOwner {
        require(
            newImplementation != address(0),
            "Invalid implementation address"
        );
        address oldImplementation = _implementation;
        _implementation = newImplementation;
        emit ImplementationChanged(oldImplementation, newImplementation);
    }
}
