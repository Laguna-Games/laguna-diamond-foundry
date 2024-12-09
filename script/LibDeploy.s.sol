// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
// forge-ignore: 5574

import {Script} from '../lib/forge-std/src/Script.sol';
import {console} from '../lib/forge-std/src/console.sol';
import {Vm} from 'forge-std/Vm.sol';

import {DiamondCutFragment} from '../src/implementation/DiamondCutFragment.sol';
import {DiamondLoupeFragment} from '../src/implementation/DiamondLoupeFragment.sol';
import {IDiamondCut} from '../src/interfaces/IDiamondCut.sol';

import {DiamondCutFacet} from '../src/diamond/DiamondCutFacet.sol';

/// @title DiamondCutFacet Utility
/// @notice Utility functions for working with the DiamondCutFacet
/// @author Rob Sampson
library LibDeploy {
    /// @notice Get a stateless reference to the Foundry VM standard library
    /// @return vm A reference to the forge-std Vm interface
    function getVM() internal pure returns (Vm) {
        return Vm(address(uint160(uint256(keccak256('hevm cheat code'))))); //  hard reference to the Foundry VM
    }

    /// @notice Get the address of the diamond from the environment
    /// @return diamond The address of the target diamond
    function getDiamondFromEnvironment() internal view returns (address diamond) {
        Vm vm = getVM();
        diamond = vm.envOr('DIAMOND', address(0));
        if (diamond == address(0)) revert('Missing DIAMOND env var');
        if (diamond.code.length == 0) revert(string.concat('DIAMOND address has no code: ', vm.toString(diamond)));
    }

    /// @notice Remove a function selector from a diamond, if it exists, and all
    /// other functions provided by the same facet contract.
    /// @dev Only the Diamond owner can call this function
    /// @dev The DiamondLoupeFacet must be attached to the target diamond
    /// @param diamond The address of the target diamond
    /// @param functionSelector A 4-byte function selector
    /// @return facetRemoved True if the facet was present on the diamond, and detached
    function removeFacetBySelector(address diamond, bytes4 functionSelector) internal returns (bool facetRemoved) {
        address facet = getFacetBySelector(diamond, functionSelector);
        if (facet != address(0)) {
            DiamondCutFragment dc = DiamondCutFragment(diamond);
            dc.cutFacet(facet);
            return true;
        }
        return false;
    }

    /// @notice Returns the contract supplying a given function selector, on a target diamond.
    /// @dev The DiamondLoupeFacet must be attached to the target diamond
    /// @param diamond The address of the target diamond
    /// @param functionSelector The function selector
    /// @return facet The address of the facet providing the function on the diamond
    function getFacetBySelector(address diamond, bytes4 functionSelector) internal view returns (address facet) {
        DiamondLoupeFragment loupe = DiamondLoupeFragment(diamond);
        facet = loupe.facetAddress(functionSelector);
    }

    /// @notice Detaches a list of selectors from a target diamond.
    /// @dev Only the Diamond owner can call this function
    /// @dev The DiamondCutFacet.
    function removeSelectors(address diamond, bytes4[] memory selectors) internal {
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: selectors
        });

        DiamondCutFragment dc = DiamondCutFragment(diamond);
        dc.diamondCut(cut, address(0), '');
    }
}
