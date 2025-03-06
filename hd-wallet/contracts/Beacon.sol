// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@oppenzeppelin-contracts/access/Ownable2Step.sol";

contract Beacon is Ownable {
    address public implementation;

    constructor(address _implementation) Ownable(msg.sender) {
        implementation = _implementation;
    }

    function update(address _newImplementation) external onlyOwner {
        implementation = _newImplementation;
    }

    function getImplementation() external view returns (address) {
        return implementation;
    }
}
