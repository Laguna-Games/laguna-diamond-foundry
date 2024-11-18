// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC173} from '../interfaces/IERC173.sol';

/// @title DiamondOwner Facet Interface Fragment
/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
contract DiamondOwnerFragment is IERC173 {
    error CallerIsNotContractOwner();

    // /// @notice This emits when ownership of a contract changes.
    // /// @dev ERC-173
    // event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Emitted when the admin account has changed.
    /// @dev ERC-1967
    event AdminChanged(address previousAdmin, address newAdmin);

    /// @notice Get the address of the owner
    /// @return The address of the owner.
    function owner() external view returns (address) {}

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    /// @custom:emits OwnershipTransferred
    /// @custom:emits AdminChanged
    function transferOwnership(address _newOwner) external {}
}
