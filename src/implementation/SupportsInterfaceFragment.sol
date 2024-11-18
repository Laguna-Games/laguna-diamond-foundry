// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibSupportsInterface} from '../libraries/LibSupportsInterface.sol';
import {IERC165} from '../interfaces/IERC165.sol';

/// @title SupportsInterface Facet Interface Fragment
/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
contract SupportsInterfaceFragment is IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool) {}

    /// @notice Set whether an interface is implemented
    /// @dev Only the contract owner can call this function
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @param implemented `true` if the contract implements `interfaceID`
    function setSupportsInterface(bytes4 interfaceID, bool implemented) external {}

    /// @notice Set a list of interfaces as implemented or not
    /// @dev Only the contract owner can call this function
    /// @param interfaceIDs The interface identifiers, as specified in ERC-165
    /// @param allImplemented `true` if the contract implements all interfaces
    function setSupportsInterfaces(bytes4[] calldata interfaceIDs, bool allImplemented) external {}

    /// @notice Returns a list of interfaces that have (ever) been supported
    /// @return The list of interfaces
    function interfaces() external view returns (LibSupportsInterface.KnownInterface[] memory) {}
}
