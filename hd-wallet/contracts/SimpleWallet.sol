// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleWallet {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    receive() external payable {}

    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "only the Owner can call this function");
        payable(owner).transfer(amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
