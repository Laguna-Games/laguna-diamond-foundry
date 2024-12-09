// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
// forge-ignore: 5574

// import {Script} from '../lib/forge-std/src/Script.sol';
import {console} from '../lib/forge-std/src/console.sol';
import {IDiamondCut} from '../src/interfaces/IDiamondCut.sol';
import {DiamondCutFacet} from '../src/diamond/DiamondCutFacet.sol';
import {LibDeploy} from './LibDeploy.s.sol';
import {AbstractFacetUtil} from './AbstractFacetUtil.s.sol';

/// @title DiamondCutFacet Utility
/// @notice Utility functions for working with the DiamondCutFacet
/// @author Rob Sampson
contract DiamondCutFacetUtil is AbstractFacetUtil {
    /// @notice Deploys a new DiamondCutFacet, or uses a pre-deployed one if available
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Specify the DiamondCutFacet address in the DIAMOND_CUT_FACET env var
    /// @return facet The address of the DiamondCutFacet
    function getOrDeployFacet() public override returns (address facet) {
        // check if we already have a facetAddress deployed
        if (facetAddress != address(0)) return facetAddress;

        // check if a DiamondCutFacet was specified in DIAMOND_CUT_FACET env var
        facetAddress = vm.envOr('DIAMOND_CUT_FACET', address(0));

        if (facetAddress == address(0)) {
            facetAddress = deployFacet(); //  no DiamondCutFacet found - deploy a new one
        } else if (facetAddress.code.length == 0) {
            revert(string.concat('DiamondCutFacet has no code: ', vm.toString(facetAddress)));
        } else {
            console.log(string.concat('Using pre-deployed DiamondCutFacet: ', vm.toString(facetAddress)));
        }
        return facetAddress;
    }

    /// @notice Returns the list of public selectors belonging to the DiamondCutFacet
    /// @return selectors List of selectors
    function getSelectorList() public pure override returns (bytes4[] memory selectors) {
        // NOTE: IDiamondCut.diamondCut.selector (0x1f931c1c) is injected automatically by the diamond constructor
        // This selector must never be included in the facet list
        selectors = new bytes4[](6);
        selectors[0] = 0xe57e69c6; // bytes4(keccak256("diamondCut((address,uint8,bytes4[])[])"))
        selectors[1] = DiamondCutFacet.cutSelector.selector;
        selectors[2] = DiamondCutFacet.deleteSelector.selector;
        selectors[3] = DiamondCutFacet.cutSelectors.selector;
        selectors[4] = DiamondCutFacet.deleteSelectors.selector;
        selectors[5] = DiamondCutFacet.cutFacet.selector;
    }

    /// @notice Deploys a new DiamondCutFacet smart contract
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @return facet The address of the DiamondCutFacet
    function deployFacet() public override returns (address facet) {
        facet = address(new DiamondCutFacet());
        console.log(string.concat('Deployed DiamondCutFacet at: ', vm.toString(facet)));
    }

    /// @notice Attaches the DiamondCutFacet to a Diamond contract
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev The diamond must ALREADY have the diamondCut (0x1f931c1c) selector attached
    function attachFacetToDiamond(address diamond) public override {
        getOrDeployFacet();
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = generateCut(facetAddress);
        IDiamondCut(diamond).diamondCut(cuts, address(0), '');
    }

    /// @notice Creates a FacetCut object for attaching a DiamondCutFacet to a Diamond
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
        // NOTE: We need to be EXTREMELY CAREFUL when removing selectors around diamondCut!
        // If the original (0x1f931c1c) diamondCut() method is removed, we can never
        // use the diamond again!

        // DO NOT use removeFacetBySelector or cutFacet or any other method that detaches a full facet at once!

        // DO NOT COPY THIS CODE FOR OTHER FACETS!!

        LibDeploy.removeSelectors(diamond, getSelectorList());
    }
}
