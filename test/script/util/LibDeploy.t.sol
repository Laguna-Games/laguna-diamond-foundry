// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../../lib/forge-std/src/Test.sol';
import {console} from '../../../lib/forge-std/src/console.sol';
import {Vm} from '../../../lib/forge-std/src/Vm.sol';

import {Diamond} from '../../../src/diamond/LGDiamond.sol';
import {DiamondCutFacet} from '../../../src/diamond/DiamondCutFacet.sol';
import {DiamondLoupeFacet} from '../../../src/diamond/DiamondLoupeFacet.sol';
import {DiamondProxyFacet} from '../../../src/diamond/DiamondProxyFacet.sol';
import {DiamondOwnerFacet} from '../../../src/diamond/DiamondOwnerFacet.sol';
import {SupportsInterfaceFacet} from '../../../src/diamond/SupportsInterfaceFacet.sol';
import {IDiamondCut} from '../../../src/interfaces/IDiamondCut.sol';

import {DiamondCutDeployLib} from '../../../script/util/DiamondCutDeployLib.s.sol';
import {DiamondLoupeDeployLib} from '../../../script/util/DiamondLoupeDeployLib.s.sol';
import {DiamondProxyDeployLib} from '../../../script/util/DiamondProxyDeployLib.s.sol';
import {CutDiamondDeployLib} from '../../../script/util/CutDiamondDeployLib.s.sol';
import {LibDeploy, Deploy} from '../../../script/util/LibDeploy.s.sol';

contract LibDeployTest is Test {
    // bool constant TEST_ENVIRONMENT_VARIABLES = true; // If tests are randomly crashing, set this to false

    // address private owner = makeAddr('owner');

    function setUp() public {}

    function tearDown() public {}

    function testDeployBlankDiamond() public {
        Deploy memory deployment = LibDeploy.deployBlankDiamond();
        assertNotEq(deployment.diamondCutFacet, address(0), 'DiamondCutFacet not deployed');
        assertNotEq(deployment.diamond, address(0), 'Diamond contract not deployed');
        assertNotEq(deployment.diamondOwner, address(0), 'Diamond owner not set');
        assertNotEq(deployment.diamondCutFacet, deployment.diamond, 'Diamond and Facet have same address');
        assertNotEq(deployment.diamond, deployment.diamondOwner, 'Diamond and owner have same address');
        assertGt(LibDeploy.codeSize(deployment.diamondCutFacet), 0, 'DiamondCutFacet has no code');
        assertGt(LibDeploy.codeSize(deployment.diamond), 0, 'Diamond has no code');
        assertEq(deployment.diamondOwner, address(this), 'Diamond owner is not deployer');
    }

    function testDeployFullDiamond() public {
        Deploy memory deployment = LibDeploy.deployFullDiamond();
        DiamondLoupeFacet loupe = DiamondLoupeFacet(deployment.diamond);
        DiamondOwnerFacet owned = DiamondOwnerFacet(deployment.diamond);
        DiamondProxyFacet proxy = DiamondProxyFacet(deployment.diamond);
        SupportsInterfaceFacet inter = SupportsInterfaceFacet(deployment.diamond);

        //  Facets should be deployed with an address
        assertNotEq(deployment.diamondCutFacet, address(0), 'DiamondCutFacet not deployed');
        assertNotEq(deployment.diamondLoupeFacet, address(0), 'DiamondLoupeFacet not deployed');
        assertNotEq(deployment.diamondOwnerFacet, address(0), 'DiamondOwnerFacet not deployed');
        assertNotEq(deployment.diamondProxyFacet, address(0), 'DiamondProxyFacet not deployed');
        assertNotEq(deployment.supportsInterfaceFacet, address(0), 'SupportsInterfaceFacet not deployed');
        assertNotEq(deployment.implementation, address(0), 'Implementation not deployed');
        assertNotEq(deployment.diamond, address(0), 'Diamond contract not deployed');
        assertNotEq(deployment.diamondOwner, address(0), 'Diamond owner not set');

        //  Facets should have bytecode
        assertGt(LibDeploy.codeSize(deployment.diamondCutFacet), 0, 'DiamondCutFacet has no code');
        assertGt(LibDeploy.codeSize(deployment.diamondLoupeFacet), 0, 'DiamondLoupeFacet has no code');
        assertGt(LibDeploy.codeSize(deployment.diamondOwnerFacet), 0, 'DiamondOwnerFacet has no code');
        assertGt(LibDeploy.codeSize(deployment.diamondProxyFacet), 0, 'DiamondProxyFacet has no code');
        assertGt(LibDeploy.codeSize(deployment.supportsInterfaceFacet), 0, 'SupportsInterfaceFacet has no code');
        assertGt(LibDeploy.codeSize(deployment.implementation), 0, 'Implementation has no code');
        assertGt(LibDeploy.codeSize(deployment.diamond), 0, 'Diamond has no code');

        //  Owner was set
        assertEq(deployment.diamondOwner, address(this), 'Diamond owner is not deployer');
        assertEq(owned.owner(), address(this), 'Diamond owner is not this test contract');
        assertEq(owned.owner(), deployment.diamondOwner, 'Deployer got the wrong diamondOwner');
        assertNotEq(owned.owner(), address(0), 'Diamond owner is unset');

        //  SupportsInterface set
        assertTrue(inter.supportsInterface(0x01ffc9a7), 'supportsInterface(type(IERC165)) = false');
        assertTrue(inter.supportsInterface(0x1f931c1c), 'supportsInterface(type(IDiamondCut)) = false');
        assertTrue(inter.supportsInterface(0x48e2b093), 'supportsInterface(type(IDiamondLoupe)) = false');
        assertTrue(inter.supportsInterface(0x7f5828d0), 'supportsInterface(type(IERC173)) = false');
        assertTrue(inter.supportsInterface(0x8da5cb5b), 'supportsInterface(type(EIP5313)) = false');

        //  Implementation proxy set
        assertEq(proxy.implementation(), deployment.implementation, 'Diamond implementation is incorrect');

        //  Functions all point to their facets
        assertEq(
            loupe.facetAddress(0xe57e69c6),
            deployment.diamondCutFacet,
            '0xe57e69c6 selector not pointing to DiamondCutFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondCutFacet.cutSelector.selector),
            deployment.diamondCutFacet,
            'DiamondCutFacet.cutSelector selector not pointing to DiamondCutFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondCutFacet.deleteSelector.selector),
            deployment.diamondCutFacet,
            'DiamondCutFacet.deleteSelector selector not pointing to DiamondCutFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondCutFacet.cutSelectors.selector),
            deployment.diamondCutFacet,
            'DiamondCutFacet.cutSelectors selector not pointing to DiamondCutFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondCutFacet.deleteSelectors.selector),
            deployment.diamondCutFacet,
            'DiamondCutFacet.deleteSelectors selector not pointing to DiamondCutFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondCutFacet.cutFacet.selector),
            deployment.diamondCutFacet,
            'DiamondCutFacet.cutFacet selector not pointing to DiamondCutFacet'
        );

        assertEq(
            loupe.facetAddress(DiamondLoupeFacet.facets.selector),
            deployment.diamondLoupeFacet,
            'DiamondLoupeFacet.facets selector not pointing to DiamondLoupeFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondLoupeFacet.facetFunctionSelectors.selector),
            deployment.diamondLoupeFacet,
            'DiamondLoupeFacet.facetFunctionSelectors selector not pointing to DiamondLoupeFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondLoupeFacet.facetAddresses.selector),
            deployment.diamondLoupeFacet,
            'DiamondLoupeFacet.facetAddresses selector not pointing to DiamondLoupeFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondLoupeFacet.facetAddress.selector),
            deployment.diamondLoupeFacet,
            'DiamondLoupeFacet.facetAddress selector not pointing to DiamondLoupeFacet'
        );

        assertEq(
            loupe.facetAddress(DiamondOwnerFacet.owner.selector),
            deployment.diamondOwnerFacet,
            'DiamondOwnerFacet.owner selector not pointing to DiamondOwnerFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondOwnerFacet.transferOwnership.selector),
            deployment.diamondOwnerFacet,
            'DiamondOwnerFacet.transferOwnership selector not pointing to DiamondOwnerFacet'
        );

        assertEq(
            loupe.facetAddress(DiamondProxyFacet.setImplementation.selector),
            deployment.diamondProxyFacet,
            'DiamondProxyFacet.setImplementation selector not pointing to DiamondProxyFacet'
        );
        assertEq(
            loupe.facetAddress(DiamondProxyFacet.implementation.selector),
            deployment.diamondProxyFacet,
            'DiamondProxyFacet.implementation selector not pointing to DiamondProxyFacet'
        );

        assertEq(
            loupe.facetAddress(SupportsInterfaceFacet.supportsInterface.selector),
            deployment.supportsInterfaceFacet,
            'SupportsInterfaceFacet.supportsInterface selector not pointing to SupportsInterfaceFacet'
        );
        assertEq(
            loupe.facetAddress(SupportsInterfaceFacet.setSupportsInterface.selector),
            deployment.supportsInterfaceFacet,
            'SupportsInterfaceFacet.setSupportsInterface selector not pointing to SupportsInterfaceFacet'
        );
        assertEq(
            loupe.facetAddress(SupportsInterfaceFacet.setSupportsInterfaces.selector),
            deployment.supportsInterfaceFacet,
            'SupportsInterfaceFacet.setSupportsInterfaces selector not pointing to SupportsInterfaceFacet'
        );
        assertEq(
            loupe.facetAddress(SupportsInterfaceFacet.interfaces.selector),
            deployment.supportsInterfaceFacet,
            'SupportsInterfaceFacet.interfaces selector not pointing to SupportsInterfaceFacet'
        );
    }

    //  TODO - add more tests for other Library methods
}
