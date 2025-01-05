// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// forge-ignore: 5574

import {console} from '../../lib/forge-std/src/console.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {DiamondCutFacet} from '../../src/diamond/DiamondCutFacet.sol';
import {LibDeploy} from './LibDeploy.s.sol';

library DiamondCutDeployLib {
    string public constant FACET_NAME = 'DiamondCutFacet';
    string public constant ENV_NAME = 'DIAMOND_CUT_FACET';

    /// @notice Returns the list of public selectors belonging to the DiamondCutFacet
    /// @return selectors List of selectors
    function getSelectorList() internal pure returns (bytes4[] memory selectors) {
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
        facet = address(new DiamondCutFacet());
        console.log(string.concat(string.concat('Deployed ', FACET_NAME, ' at: ', LibDeploy.getVM().toString(facet))));
    }

    /// @notice Attaches a facet to a diamond
    function attachFacetToDiamond(address diamond, address facet) internal {
        LibDeploy.cutFacetOntoDiamond(FACET_NAME, generateFacetCut(facet), diamond);
    }

    /// @notice Removes the DiamondCutFacet from a Diamond (except for the original diamondCut() method)
    function removeFacetFromDiamond(address diamond) internal {
        // NOTE: We need to be EXTREMELY CAREFUL when removing selectors around diamondCut!
        // If the original (0x1f931c1c) diamondCut() method is removed, we can never
        // use the diamond again!

        // DO NOT use removeFacetBySelector or cutFacet or any other method that detaches a full facet at once!

        // DO NOT COPY THIS CODE FOR OTHER FACETS!!

        LibDeploy.removeSelectors(diamond, getSelectorList());
    }
}
