// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC165} from '../interfaces/IERC165.sol';
import {LibContractOwner} from '../libraries/LibContractOwner.sol';
import {LibSupportsInterface} from '../libraries/LibSupportsInterface.sol';

/// @title LG implementation of ERC-165 Standard Interface Detection
/// @author rsampson@laguna.games
contract SupportsInterfaceFacet is IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return LibSupportsInterface.supportsInterface(interfaceID);
    }

    /// @notice Set whether an interface is implemented
    /// @dev Only the contract owner can call this function
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @param implemented `true` if the contract implements `interfaceID`
    function setSupportsInterface(bytes4 interfaceID, bool implemented) external {
        LibContractOwner.enforceIsContractOwner();
        LibSupportsInterface.setSupportsInterface(interfaceID, implemented);
    }

    /// @notice Set a list of interfaces as implemented or not
    /// @dev Only the contract owner can call this function
    /// @param interfaceIDs The interface identifiers, as specified in ERC-165
    /// @param allImplemented `true` if the contract implements all interfaces
    function setSupportsInterfaces(bytes4[] calldata interfaceIDs, bool allImplemented) external {
        LibContractOwner.enforceIsContractOwner();
        for (uint i = 0; i < interfaceIDs.length; ++i) {
            LibSupportsInterface.setSupportsInterface(interfaceIDs[i], allImplemented);
        }
    }

    /// @notice Returns a list of interfaces that have (ever) been supported
    /// @return The list of interfaces
    function interfaces() external view returns (LibSupportsInterface.KnownInterface[] memory) {
        return LibSupportsInterface.getKnownInterfaces();
    }
}
