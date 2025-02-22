// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IDiamondLoupe} from '../interfaces/IDiamondLoupe.sol';

/// @title DiamondLoupe Facet Interface Fragment
/// @dev Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
contract DiamondLoupeFragment {
    /// @notice Gets all facets and their selectors.
    /// @return facets_ Facet
    function facets() external view returns (IDiamondLoupe.Facet[] memory facets_) {}

    /// @notice Gets all the function selectors provided by a facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_) {}

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view returns (address[] memory facetAddresses_) {}

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_) {}
}
