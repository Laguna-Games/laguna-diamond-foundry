// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../../lib/forge-std/src/Test.sol';
import {console} from '../../../lib/forge-std/src/console.sol';
import {Vm} from 'forge-std/Vm.sol';

import {Diamond} from '../../../src/diamond/LGDiamond.sol';
import {DiamondCutFacet} from '../../../src/diamond/DiamondCutFacet.sol';
import {DiamondLoupeFacet} from '../../../src/diamond/DiamondLoupeFacet.sol';
import {IDiamondCut} from '../../../src/interfaces/IDiamondCut.sol';

import {DiamondCutDeployLib} from '../../../script/util/DiamondCutDeployLib.s.sol';
import {DiamondLoupeDeployLib} from '../../../script/util/DiamondLoupeDeployLib.s.sol';
import {LibDeploy} from '../../../script/util/LibDeploy.s.sol';

contract DiamondCutDeployLibTest is Test {
    bool constant TEST_ENVIRONMENT_VARIABLES = false; // If tests are randomly crashing, set this to false

    // address private owner = makeAddr('owner');

    function setUp() public {}

    function tearDown() public {}

    /// @dev If set, the util should return the cached facet address
    function testGetSelectorList() public pure {
        bytes4[] memory selectors = DiamondCutDeployLib.getSelectorList();
        bool found0xe57e69c6 = false;
        bool foundCutSelector = false;
        bool foundDeleteSelector = false;
        bool foundCutSelectors = false;
        bool foundDeleteSelectors = false;
        bool foundCutFacet = false;

        for (uint i = 0; i < selectors.length; i++) {
            if (selectors[i] == 0xe57e69c6) found0xe57e69c6 = true;
            if (selectors[i] == DiamondCutFacet.cutSelector.selector) foundCutSelector = true;
            if (selectors[i] == DiamondCutFacet.deleteSelector.selector) foundDeleteSelector = true;
            if (selectors[i] == DiamondCutFacet.cutSelectors.selector) foundCutSelectors = true;
            if (selectors[i] == DiamondCutFacet.deleteSelectors.selector) foundDeleteSelectors = true;
            if (selectors[i] == DiamondCutFacet.cutFacet.selector) foundCutFacet = true;
        }

        assertTrue(found0xe57e69c6, '0xe57e69c6 not found');
        assertTrue(foundCutSelector, 'DiamondCutFacet.cutSelector.selector not found');
        assertTrue(foundDeleteSelector, 'DiamondCutFacet.deleteSelector.selector not found');
        assertTrue(foundCutSelectors, 'DiamondCutFacet.cutSelectors.selector not found');
        assertTrue(foundDeleteSelectors, 'DiamondCutFacet.deleteSelectors.selector not found');
        assertTrue(foundCutFacet, 'DiamondCutFacet.cutFacet.selector not found');
    }

    function testGenerateFacetCut(address fuzzAddress1) public pure {
        vm.assume(fuzzAddress1 != address(0));

        IDiamondCut.FacetCut memory cut = DiamondCutDeployLib.generateFacetCut(fuzzAddress1);

        assertEq(cut.facetAddress, fuzzAddress1, 'Facet address didnt set correctly');
        assertEq(uint(cut.action), uint(IDiamondCut.FacetCutAction.Add), 'Facet action is not "Add');

        bool found0xe57e69c6 = false;
        bool foundCutSelector = false;
        bool foundDeleteSelector = false;
        bool foundCutSelectors = false;
        bool foundDeleteSelectors = false;
        bool foundCutFacet = false;

        for (uint i = 0; i < cut.functionSelectors.length; i++) {
            if (cut.functionSelectors[i] == 0xe57e69c6) found0xe57e69c6 = true;
            if (cut.functionSelectors[i] == DiamondCutFacet.cutSelector.selector) foundCutSelector = true;
            if (cut.functionSelectors[i] == DiamondCutFacet.deleteSelector.selector) foundDeleteSelector = true;
            if (cut.functionSelectors[i] == DiamondCutFacet.cutSelectors.selector) foundCutSelectors = true;
            if (cut.functionSelectors[i] == DiamondCutFacet.deleteSelectors.selector) foundDeleteSelectors = true;
            if (cut.functionSelectors[i] == DiamondCutFacet.cutFacet.selector) foundCutFacet = true;
        }

        assertTrue(found0xe57e69c6, '0xe57e69c6 not found');
        assertTrue(foundCutSelector, 'DiamondCutFacet.cutSelector.selector not found');
        assertTrue(foundDeleteSelector, 'DiamondCutFacet.deleteSelector.selector not found');
        assertTrue(foundCutSelectors, 'DiamondCutFacet.cutSelectors.selector not found');
        assertTrue(foundDeleteSelectors, 'DiamondCutFacet.deleteSelectors.selector not found');
        assertTrue(foundCutFacet, 'DiamondCutFacet.cutFacet.selector not found');
    }

    /// NOTE: This messes with global state in the environment variables
    /// This has a good chance of messing up other tests when running in parallel...
    function testGetInjectedOrNewFacetInstancePrefersEnv() public {
        vm.skip(!TEST_ENVIRONMENT_VARIABLES); //  skip to avoid race conditions
        address facet = DiamondCutDeployLib.deployNewInstance();
        assertNotEq(facet, address(0), 'Facet was not deployed');
        assertGt(LibDeploy.codeSize(facet), 0, 'Facet has no code');

        string memory originalValue = vm.envOr(DiamondCutDeployLib.ENV_NAME, string(''));
        vm.setEnv(DiamondCutDeployLib.ENV_NAME, vm.toString(facet));
        address instance = DiamondCutDeployLib.getInjectedOrNewFacetInstance();
        vm.setEnv(DiamondCutDeployLib.ENV_NAME, originalValue);

        assertEq(instance, facet, 'Facet address was not taken from ENV');
    }

    /// NOTE: This messes with global state in the environment variables
    /// This has a good chance of messing up other tests when running in parallel...
    function testGetInjectedOrNewFacetInstanceRevertsOnEmptyAddress() public {
        vm.skip(!TEST_ENVIRONMENT_VARIABLES); //  skip to avoid race conditions
        address facet = makeAddr('Facet McFacetface');
        assertNotEq(facet, address(0), 'Facet address failed to be created');
        assertEq(LibDeploy.codeSize(facet), 0, 'Fake facet should not have code');

        string memory originalValue = vm.envOr(DiamondCutDeployLib.ENV_NAME, string(''));
        vm.setEnv(DiamondCutDeployLib.ENV_NAME, vm.toString(facet));
        vm.expectRevert(bytes(string.concat(DiamondCutDeployLib.ENV_NAME, ' has no code: ', vm.toString(facet))));
        DiamondCutDeployLib.getInjectedOrNewFacetInstance();
        vm.setEnv(DiamondCutDeployLib.ENV_NAME, originalValue);
    }

    /// NOTE: This messes with global state in the environment variables
    /// This has a good chance of messing up other tests when running in parallel...
    function testGetInjectedOrNewFacetInstance() public {
        vm.skip(!TEST_ENVIRONMENT_VARIABLES); //  skip to avoid race conditions
        string memory originalValue = vm.envOr(DiamondCutDeployLib.ENV_NAME, string(''));
        vm.setEnv(DiamondCutDeployLib.ENV_NAME, 'UNSET');
        string memory raw = vm.envOr(DiamondCutDeployLib.ENV_NAME, string('UNSET'));
        address instance = DiamondCutDeployLib.getInjectedOrNewFacetInstance();
        vm.setEnv(DiamondCutDeployLib.ENV_NAME, originalValue);

        address control = LibDeploy.parseAddress('UNSET'); //  should be address(0)
        address env = LibDeploy.parseAddress(raw); //  should be address(0)

        assertEq(control, address(0), 'Control address was not address(0)');
        assertEq(env, address(0), 'env address was not address(0)'); //  This means the env var was not un-set, or got overwritten
        assertNotEq(instance, address(0), 'Facet instance was not deployed');
    }

    function testDeployNewInstance() public {
        address facet = DiamondCutDeployLib.deployNewInstance();
        assertNotEq(facet, address(0), 'Facet was not deployed');
        assertGt(LibDeploy.codeSize(facet), 0, 'Facet has no code');

        address facet2 = DiamondCutDeployLib.deployNewInstance();
        assertNotEq(facet2, address(0), 'Facet was not deployed');
        assertGt(LibDeploy.codeSize(facet2), 0, 'Facet has no code');
        assertNotEq(facet, facet2, 'Facet addresses were the same');

        assertEq(facet.code.length, facet2.code.length);
    }

    function testAttachFacetToDiamond() public {
        address diamondCutFacet = DiamondCutDeployLib.deployNewInstance();
        assertNotEq(diamondCutFacet, address(0), 'Facet was not deployed');
        address diamond = address(new Diamond(diamondCutFacet));
        address diamondLoupeFacet = DiamondLoupeDeployLib.deployNewInstance();
        DiamondLoupeDeployLib.attachFacetToDiamond(diamond, diamondLoupeFacet);
        DiamondCutDeployLib.attachFacetToDiamond(diamond, diamondCutFacet);

        DiamondLoupeFacet loupe = DiamondLoupeFacet(diamond);
        bytes4[] memory selectors = DiamondCutDeployLib.getSelectorList();
        for (uint i = 0; i < selectors.length; i++) {
            assertEq(
                loupe.facetAddress(selectors[i]),
                diamondCutFacet,
                string.concat('Selector ', vm.toString(selectors[i]), ' is not attached to diamondCutFacet')
            );
        }
    }

    function testRemoveFacetFromDiamond() public {
        address diamondCutFacet = DiamondCutDeployLib.deployNewInstance();
        assertNotEq(diamondCutFacet, address(0), 'Facet was not deployed');
        address diamond = address(new Diamond(diamondCutFacet));
        address diamondLoupeFacet = DiamondLoupeDeployLib.deployNewInstance();
        DiamondLoupeDeployLib.attachFacetToDiamond(diamond, diamondLoupeFacet);
        DiamondCutDeployLib.attachFacetToDiamond(diamond, diamondCutFacet);

        DiamondLoupeFacet loupe = DiamondLoupeFacet(diamond);
        bytes4[] memory selectors = DiamondCutDeployLib.getSelectorList();
        for (uint i = 0; i < selectors.length; i++) {
            assertEq(
                loupe.facetAddress(selectors[i]),
                diamondCutFacet,
                string.concat('Selector ', vm.toString(selectors[i]), ' is not attached to diamondCutFacet')
            );
        }

        DiamondCutDeployLib.removeFacetFromDiamond(diamond);
        for (uint i = 0; i < selectors.length; i++) {
            assertEq(
                loupe.facetAddress(selectors[i]),
                address(0),
                string.concat('Selector ', vm.toString(selectors[i]), ' is still attached to diamondCutFacet')
            );
        }

        assertEq(loupe.facetAddress(IDiamondCut.diamondCut.selector), diamondCutFacet, '0xe57e69c6 was removed!');
    }
}
