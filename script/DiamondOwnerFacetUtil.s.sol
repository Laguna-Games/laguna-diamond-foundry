// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
// forge-ignore: 5574

// import {Script} from '../lib/forge-std/src/Script.sol';
import {console} from '../lib/forge-std/src/console.sol';
import {IDiamondCut} from '../src/interfaces/IDiamondCut.sol';
import {DiamondOwnerFacet} from '../src/diamond/DiamondOwnerFacet.sol';
import {LibDeploy} from './LibDeploy.s.sol';
import {AbstractFacetUtil} from './AbstractFacetUtil.s.sol';

/// @title DiamondOwnerFacet Utility
/// @notice Utility functions for working with the DiamondOwnerFacet
/// @author Rob Sampson
contract DiamondOwnerFacetUtil is AbstractFacetUtil {
    /// @notice Deploys a new DiamondOwnerFacet, or uses a pre-deployed one if available
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Specify the DiamondOwnerFacet address in the DIAMOND_OWNER_FACET env var
    /// @return facet The address of the DiamondOwnerFacet
    function getOrDeployFacet() public override returns (address facet) {
        // check if we already have a facetAddress deployed
        if (facetAddress != address(0)) return facetAddress;

        // check if a DiamondOwnerFacet was specified in DIAMOND_OWNER_FACET env var
        facetAddress = vm.envOr('DIAMOND_OWNER_FACET', address(0));

        if (facetAddress == address(0)) {
            facetAddress = deployFacet(); //  no DiamondOwnerFacet found - deploy a new one
        } else if (facetAddress.code.length == 0) {
            revert(string.concat('DiamondOwnerFacet has no code: ', vm.toString(facetAddress)));
        } else {
            console.log(string.concat('Using pre-deployed DiamondOwnerFacet: ', vm.toString(facetAddress)));
        }
        return facetAddress;
    }

    /// @notice Returns the list of public selectors belonging to the DiamondOwnerFacet
    /// @return selectors List of selectors
    function getSelectorList() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](2);
        selectors[0] = DiamondOwnerFacet.owner.selector;
        selectors[1] = DiamondOwnerFacet.transferOwnership.selector;
    }

    /// @notice Deploys a new DiamondOwnerFacet smart contract
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @return facet The address of the DiamondOwnerFacet
    function deployFacet() public override returns (address facet) {
        facet = address(new DiamondOwnerFacet());
        console.log(string.concat('Deployed DiamondOwnerFacet at: ', vm.toString(facet)));
    }

    /// @notice Attaches the DiamondOwnerFacet to a Diamond contract
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    function attachFacetToDiamond(address diamond) public override {
        getOrDeployFacet();
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = generateCut(facetAddress);
        IDiamondCut(diamond).diamondCut(cuts, address(0), '');
    }

    /// @notice Creates a FacetCut object for attaching a DiamondOwnerFacet to a Diamond
    /// @dev This method is exposed to allow multiple cuts to be bundled in one call
    /// @param facet The address of the facet to attach
    /// @return cut The `Add` FacetCut object
    function generateCut(address facet) public pure override returns (IDiamondCut.FacetCut memory cut) {
        cut = IDiamondCut.FacetCut({
            facetAddress: facet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectorList()
        });
    }

    /// @notice Removes the DiamondCutFacet from a Diamond (except for the original diamondCut() method)
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    function removeFacetFromDiamond(address diamond) public override {
        // NOTE: this is a greedy cleanup - for all selectors in the list, their entire facet will be removed
        // This helps when an older facet has extra deprecated endpoints, but it can cause issues if unexpected
        bytes4[] memory selectors = getSelectorList();
        for (uint256 i = 0; i < selectors.length; i++) {
            LibDeploy.removeFacetBySelector(diamond, selectors[i]);
        }
    }
}
