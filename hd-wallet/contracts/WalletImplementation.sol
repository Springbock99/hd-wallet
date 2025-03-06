// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@oppenzeppelin-contracts/access/Ownable2Step.sol";

contract WalletImplementation is Ownable {
    constructor() Ownable(msg.sender) {}

    receive() external payable {}

    function withdraw(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
