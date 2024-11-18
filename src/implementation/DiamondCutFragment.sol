// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IDiamondCut} from '../interfaces/IDiamondCut.sol';

/// @title DiamondCutFacet Interface Fragment
/// @dev Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
contract DiamondCutFragment {
    error InvalidFacetCutAction(IDiamondCut.FacetCutAction action);

    /// @notice Emitted when facets are added or removed
    /// @dev ERC-2535
    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @dev The LG implementation DOES NOT SUPPORT initializers!
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    /// @custom:selector 0x1f931c1c == bytes4(keccak256("diamondCut((address,uint8,bytes4[])[],address,bytes)"))
    function diamondCut(
        IDiamondCut.FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external {}

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @dev This is a convenience implementation of the above
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @custom:selector 0xe57e69c6 == bytes4(keccak256("diamondCut((address,uint8,bytes4[])[])"))
    function diamondCut(IDiamondCut.FacetCut[] calldata _diamondCut) external {}

    /// @notice Removes one selector from the Diamond, using DiamondCut
    /// @param selector - The byte4 signature for a method selector to remove
    /// @custom:emits DiamondCut
    function cutSelector(bytes4 selector) external {}

    /// @notice Removes one selector from the Diamond, using removeFunction()
    /// @param selector - The byte4 signature for a method selector to remove
    function deleteSelector(bytes4 selector) external {}

    /// @notice Removes many selectors from the Diamond, using DiamondCut
    /// @param selectors - Array of byte4 signatures for method selectors to remove
    /// @custom:emits DiamondCut
    function cutSelectors(bytes4[] memory selectors) external {}

    /// @notice Removes many selectors from the Diamond, using removeFunctions()
    /// @param selectors - Array of byte4 signatures for method selectors to remove
    function deleteSelectors(bytes4[] memory selectors) external {}

    /// @notice Removes any selectors from the Diamond that come from a target
    /// @notice contract address, using DiamondCut.
    /// @param facet - The address of the Facet smart contract to remove
    /// @custom:emits DiamondCut
    function cutFacet(address facet) external {}
}
