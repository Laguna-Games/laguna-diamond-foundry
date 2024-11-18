// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibContractOwner} from '../libraries/LibContractOwner.sol';

/// @title Library for the common LG implementation of ERC-165
/// @author rsampson@laguna.games
/// @custom:storage-location erc7201:games.laguna.LibSupportsInterface
library LibSupportsInterface {
    bytes32 public constant SUPPORTS_INTERFACE_STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256('games.laguna.LibSupportsInterface')) - 1)) & ~bytes32(uint256(0xff));

    struct KnownInterface {
        bytes4 selector;
        bool supported;
    }

    struct SupportsInterfaceStorage {
        mapping(bytes4 selector => bool supported) supportedInterfaces;
        bytes4[] interfaces;
    }

    /// @notice Storage slot for SupportsInterface state data
    function supportsInterfaceStorage() internal pure returns (SupportsInterfaceStorage storage storageSlot) {
        bytes32 position = SUPPORTS_INTERFACE_STORAGE_POSITION;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            storageSlot.slot := position
        }
    }

    /// @notice Checks if a contract implements an interface
    /// @param _interfaceId Interface ID to check
    /// @return true if the contract implements the interface
    function supportsInterface(bytes4 _interfaceId) internal view returns (bool) {
        return supportsInterfaceStorage().supportedInterfaces[_interfaceId];
    }

    /// @notice Sets whether a contract implements an interface
    /// @param _interfaceId Interface ID to set
    /// @param _implemented true if the contract implements the interface
    function setSupportsInterface(bytes4 _interfaceId, bool _implemented) internal {
        SupportsInterfaceStorage storage s = supportsInterfaceStorage();

        if (_implemented && !s.supportedInterfaces[_interfaceId]) {
            s.interfaces.push(_interfaceId);
        }

        s.supportedInterfaces[_interfaceId] = _implemented;
    }

    /// @notice Returns the list of interfaces this contract has supported, and whether they are supported currently.
    /// @return The list of interfaces
    function getKnownInterfaces() internal view returns (KnownInterface[] memory) {
        SupportsInterfaceStorage storage s = supportsInterfaceStorage();
        KnownInterface[] memory interfaces = new KnownInterface[](s.interfaces.length);
        for (uint i = 0; i < s.interfaces.length; ++i) {
            interfaces[i] = KnownInterface({
                selector: s.interfaces[i],
                supported: s.supportedInterfaces[s.interfaces[i]]
            });
        }
        return interfaces;
    }

    /// @notice Calculate the interface ID for a list of function selectors
    /// @dev Per ERC-165: "We define the interface identifier as the XOR of all function selectors in the interface"
    /// @param functionSelectors The list of function selectors in the interface
    /// @return interfaceId The ERC-165 interface ID
    function calculateInterfaceId(bytes4[] memory functionSelectors) internal pure returns (bytes4 interfaceId) {
        for (uint256 i = 0; i < functionSelectors.length; ++i) {
            interfaceId ^= functionSelectors[i];
        }
    }
}
