// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
// forge-ignore: 5574

import {Script} from '../lib/forge-std/src/Script.sol';
import {console} from '../lib/forge-std/src/console.sol';
import {IDiamondCut} from '../src/interfaces/IDiamondCut.sol';

/// @title Abstract Facet Util
/// @notice Template for utility scripts
/// @author Rob Sampson
abstract contract AbstractFacetUtil is Script {
    address public facetAddress;

    /// @notice Deploys a new Facet instance, or uses a pre-deployed one if available
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @return facet The address of the deployed facet
    function getOrDeployFacet() public virtual returns (address facet) {}

    /// @notice Returns the list of public selectors belonging to the Facet contract
    /// @return selectors List of selectors
    function getSelectorList() public pure virtual returns (bytes4[] memory selectors) {}

    /// @notice Deploys a new facet smart contract instance
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @return facet The address of the deployed facet
    function deployFacet() public virtual returns (address facet) {}

    /// @notice Attaches the facet to a Diamond contract
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    function attachFacetToDiamond(address diamond) public virtual {}

    /// @notice Creates a FacetCut object for attaching a facet to a Diamond
    /// @dev This method is exposed to allow multiple cuts to be bundled in one call
    /// @param facet The address of the facet to attach
    /// @return cut The `Add` FacetCut object
    function generateCut(address facet) public pure virtual returns (IDiamondCut.FacetCut memory cut) {}

    /// @notice Removes the facet from a Diamond
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    function removeFacetFromDiamond(address diamond) public virtual {}

    // add this to be excluded from coverage report
    function test() public virtual {}
}
