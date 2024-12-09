// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
// forge-ignore: 5574

// import {Script} from '../lib/forge-std/src/Script.sol';
import {console} from '../lib/forge-std/src/console.sol';
import {IDiamondCut} from '../src/interfaces/IDiamondCut.sol';
import {DiamondProxyFacet} from '../src/diamond/DiamondProxyFacet.sol';
import {LibDeploy} from './LibDeploy.s.sol';
import {AbstractFacetUtil} from './AbstractFacetUtil.s.sol';

/// @title DiamondProxyFacet Utility
/// @notice Utility functions for working with the DiamondProxyFacet
/// @author Rob Sampson
contract DiamondProxyFacetUtil is AbstractFacetUtil {
    /// @notice Deploys a new DiamondProxyFacet, or uses a pre-deployed one if available
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Specify the DiamondProxyFacet address in the DIAMOND_PROXY_FACET env var
    /// @return facet The address of the DiamondProxyFacet
    function getOrDeployFacet() public override returns (address facet) {
        // check if we already have a facetAddress deployed
        if (facetAddress != address(0)) return facetAddress;

        // check if a DiamondProxyFacet was specified in DIAMOND_PROXY_FACET env var
        facetAddress = vm.envOr('DIAMOND_PROXY_FACET', address(0));

        if (facetAddress == address(0)) {
            facetAddress = deployFacet(); //  no DiamondProxyFacet found - deploy a new one
        } else if (facetAddress.code.length == 0) {
            revert(string.concat('DiamondProxyFacet has no code: ', vm.toString(facetAddress)));
        } else {
            console.log(string.concat('Using pre-deployed DiamondProxyFacet: ', vm.toString(facetAddress)));
        }
        return facetAddress;
    }

    /// @notice Returns the list of public selectors belonging to the DiamondProxyFacet
    /// @return selectors List of selectors
    function getSelectorList() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](2);
        selectors[0] = DiamondProxyFacet.setImplementation.selector;
        selectors[1] = DiamondProxyFacet.implementation.selector;
    }

    /// @notice Get the dummy "implementation" contract address
    /// @return The dummy "implementation" contract address
    function implementation() external view returns (address) {}

    /// @notice Deploys a new DiamondProxyFacet smart contract
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @return facet The address of the DiamondProxyFacet
    function deployFacet() public override returns (address facet) {
        facet = address(new DiamondProxyFacet());
        console.log(string.concat('Deployed DiamondProxyFacet at: ', vm.toString(facet)));
    }

    /// @notice Attaches the DiamondProxyFacet to a Diamond contract
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    function attachFacetToDiamond(address diamond) public override {
        getOrDeployFacet();
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = generateCut(facetAddress);
        IDiamondCut(diamond).diamondCut(cuts, address(0), '');
    }

    /// @notice Creates a FacetCut object for attaching a DiamondProxyFacet to a Diamond
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
