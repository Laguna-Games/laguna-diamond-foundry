// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// forge-ignore: 5574

import {console} from '../../lib/forge-std/src/console.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {DiamondProxyFacet} from '../../src/diamond/DiamondProxyFacet.sol';
import {LibDeploy} from './LibDeploy.s.sol';

library DiamondProxyDeployLib {
    string public constant FACET_NAME = 'DiamondProxyFacet';
    string public constant ENV_NAME = 'DIAMOND_PROXY_FACET';

    /// @notice Returns the list of public selectors belonging to the DiamondProxyFacet
    /// @return selectors List of selectors
    function getSelectorList() internal pure returns (bytes4[] memory selectors) {
        selectors = new bytes4[](2);
        selectors[0] = DiamondProxyFacet.setImplementation.selector;
        selectors[1] = DiamondProxyFacet.implementation.selector;
    }

    /// @notice Creates a FacetCut object for attaching a facet to a Diamond
    /// @dev This method is exposed to allow multiple cuts to be bundled in one call
    /// @param facet The address of the facet to attach
    /// @return cut The `Add` FacetCut object
    function generateFacetCut(address facet) internal pure returns (IDiamondCut.FacetCut memory cut) {
        cut = LibDeploy.facetCutGenerator(facet, getSelectorList());
    }

    /// @notice Returns the address of a deployed facet instance to use
    /// @dev Prefers the address from the CLI environment, otherwise deploys a fresh facet
    /// @return facet The address of the deployed facet
    function getInjectedOrNewFacetInstance() internal returns (address facet) {
        facet = LibDeploy.getAddressFromENV(ENV_NAME);

        if (facet == address(0)) {
            facet = deployNewInstance();
        } else {
            console.log(string.concat('Using pre-deployed ', FACET_NAME, ': ', LibDeploy.getVM().toString(facet)));
        }
    }

    /// @notice Deploys a new facet instance
    /// @return facet The address of the deployed facet
    function deployNewInstance() internal returns (address facet) {
        facet = address(new DiamondProxyFacet());
        console.log(string.concat(string.concat('Deployed ', FACET_NAME, ' at: ', LibDeploy.getVM().toString(facet))));
    }

    /// @notice Attaches a DiamondProxyFacet to a diamond
    function attachFacetToDiamond(address diamond, address facet) internal {
        LibDeploy.cutFacetOntoDiamond(FACET_NAME, generateFacetCut(facet), diamond);
    }

    /// @notice Removes the DiamondProxyFacet from a Diamond
    /// @dev NOTE: This is a greedy cleanup - use it to nuke all of an old facet (even if the old version has extra
    /// deprecated endpoints). If you are un-sure please review this code carefully before using it!
    function removeFacetFromDiamond(address diamond) internal {
        LibDeploy.cutFacetOffOfDiamond(FACET_NAME, getSelectorList(), diamond);
    }
}
