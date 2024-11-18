// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title DiamondProxy Facet Interface Fragment
/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
contract DiamondProxyFragment {
    /// @notice Emitted when the implementation is upgraded.
    /// @dev ERC-1967
    event Upgraded(address indexed implementation);

    /// @notice Sets the "implementation" contract address
    /// @param _implementation The new implementation contract
    /// @custom:emits Upgraded
    function setImplementation(address _implementation) external {}

    /// @notice Get the dummy "implementation" contract address
    /// @return The dummy "implementation" contract address
    function implementation() external view returns (address) {}
}
