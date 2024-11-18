// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Library for the common LG implementation of the "Implementation" Proxy contract.
/// @title For compatibility, we support both ERC-1967 and ERC-1822
/// @author rsampson@laguna.games
/// @notice The "implementation" here is a dummy contract to expose the diamond interface to block explorers.
/// @notice https://github.com/zdenham/diamond-etherscan/tree/main
/// @custom:storage-location erc1967:eip1967.proxy.implementation
/// @custom:storage-location erc1822:PROXIABLE
library LibProxyImplementation {
    /// @notice Emitted when the implementation is upgraded.
    /// @dev ERC-1967
    event Upgraded(address indexed implementation);

    //  @dev Standard storage slot for the ERC-1967 logic implementation address
    //  @dev bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    bytes32 internal constant ERC_1967_SLOT_POSITION =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    //  @dev Standard storage slot for the ERC-1822 logic implementation address
    //  @dev keccak256("PROXIABLE")
    bytes32 internal constant ERC_1822_SLOT_POSITION =
        0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;

    struct AddressStorageStruct {
        address value;
    }

    /// @notice Storage slot for Contract Owner state data on ERC-1967
    function proxyImplementationStorage1967() internal pure returns (AddressStorageStruct storage storageSlot) {
        bytes32 position = ERC_1967_SLOT_POSITION;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            storageSlot.slot := position
        }
    }

    /// @notice Storage slot for Contract Owner state data on ERC-1822
    function proxyImplementationStorage1822() internal pure returns (AddressStorageStruct storage storageSlot) {
        bytes32 position = ERC_1822_SLOT_POSITION;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            storageSlot.slot := position
        }
    }

    /// @notice Sets the "implementation" contract address
    /// @param newImplementation The new implementation contract
    /// @custom:emits Upgraded
    function setImplementation(address newImplementation) internal {
        //  NOTE: Save the data in known storage slots for both ERC-1967 and ERC-1822
        proxyImplementationStorage1967().value = newImplementation;
        proxyImplementationStorage1822().value = newImplementation; //  This is stored in case a 3rd party reads the storage slot directly
        emit Upgraded(newImplementation);
    }

    /// @notice Gets the "implementation" contract address
    /// @return implementation The implementation contract
    function getImplementation() internal view returns (address implementation) {
        implementation = proxyImplementationStorage1967().value;
    }
}
