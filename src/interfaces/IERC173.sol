// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ERC-173 Contract Ownership Standard
/// @dev The ERC-165 identifier for this interface is 0x7f5828d0
/// @dev https://eips.ethereum.org/EIPS/eip-173
interface IERC173 {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Get the address of the owner
    /// @return The address of the owner.
    function owner() external view returns (address);

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}

/// @title EIP-5313 Light Contract Ownership Standard
/// @dev The ERC-165 identifier for this interface is 0x8da5cb5b
/// @dev https://eips.ethereum.org/EIPS/eip-5313
interface EIP5313 {
    /// @notice Get the address of the owner
    /// @return The address of the owner
    function owner() external view returns (address);
}
