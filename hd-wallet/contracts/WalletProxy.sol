// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Beacon} from "./Beacon.sol";
import {ImplementationWallet} from "./ImplementationWallet.sol";

contract WalletProxy {
    bytes32 private constant BEACON_SLOT =
        0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Sets the beacon address and initializes the proxy.
     * @param _beacon The address of the beacon contract
     * @param _owner The address that will be set as the owner of the implementation
     */
    constructor(address _beacon, address _owner) {
        bytes32 slot = BEACON_SLOT;

        assembly {
            sstore(slot, _beacon)
        }

        (bool success, ) = getImplementation().delegatecall(
            abi.encodeWithSignature("initialize(address)", _owner)
        );
        require(success, "Initialization failed");
    }

    /**
     * @dev Returns the current implementation address from the beacon.
     */
    function getImplementation() internal view returns (address) {
        bytes32 slot = BEACON_SLOT;
        address beaconAddress;

        assembly {
            beaconAddress := sload(slot)
        }

        return Beacon(beaconAddress).getImplementation();
    }

    /**
     * @dev Fallback function that delegates calls to the implementation.
     */
    fallback() external payable {
        address _implementation = getImplementation();
        require(_implementation != address(0), "Implementation not set");

        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(
                gas(),
                _implementation,
                0,
                calldatasize(),
                0,
                0
            )

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}
