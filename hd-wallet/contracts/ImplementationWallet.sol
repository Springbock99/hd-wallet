// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";

contract ImplementationWallet is Initializable, OwnableUpgradeable {
    function initialize(address initialOwner) external initializer {
        __Ownable_init(initialOwner);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient Balance");
        payable(owner()).transfer(amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
