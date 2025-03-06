// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Beacon} from "./Beacon.sol";

contract WalletProxy {
    address public immutable beacon;

    constructor(address _beacon, address _initialOwner) {
        beacon = _beacon;
        // Initialize ownership by calling the implementation
        (bool success, ) = getImplementation().delegatecall(
            abi.encodeWithSignature("transferOwnership(address)", _initialOwner)
        );
        require(success, "Initialization failed");
    }

    function getImplementation() internal view returns (address) {
        return Beacon(beacon).implementation();
    }

    fallback() external payable {
        address impl = getImplementation();
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    receive() external payable {}
}
