// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {Diamond} from '../../src/diamond/LGDiamond.sol';
import {CutDiamond} from '../../src/diamond/CutDiamond.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {IDiamondLoupe} from '../../src/interfaces/IDiamondLoupe.sol';
import {DiamondOwnerFacet} from '../../src/diamond/DiamondOwnerFacet.sol';
import {DiamondProxyFacet} from '../../src/diamond/DiamondProxyFacet.sol';
import {DiamondCutFacet} from '../../src/diamond/DiamondCutFacet.sol';
import {DiamondLoupeFacet} from '../../src/diamond/DiamondLoupeFacet.sol';
import {SupportsInterfaceFacet} from '../../src/diamond/SupportsInterfaceFacet.sol';
import {IERC165} from '../../src/interfaces/IERC165.sol';
import {IERC173} from '../../src/interfaces/IERC173.sol';
import {Gogogo} from '../../script/Gogogo.s.sol';
import {LibDeploy, Deploy} from '../../script/util/LibDeploy.s.sol';
import {TestSnapshotFactory} from './TestSnapshotFactory.t.sol';

/// @title Diamond Factory
/// @notice This factory is used by Foundry tests to "deploy" a diamond for unit testing.
contract TestDiamondFactory is Test {
    function gogogo(address newOwner) public returns (CutDiamond cutDiamond) {
        vm.prank(newOwner);
        Deploy memory deployment = LibDeploy.deployFullDiamond();
        CutDiamond(deployment.diamond).transferOwnership(newOwner);
        return CutDiamond(deployment.diamond);
    }

    function test() public {}
}

contract TestDiamondFactoryTest is Test, TestSnapshotFactory {
    address owner = makeAddr('owner');

    function testFactory() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        CutDiamond diamond = factory.gogogo(owner);
        assertTrue(address(diamond).code.length > 0);
        assertEq(diamond.facets().length, 6); // DiamondCutFacet.diamondCut, DiamondCut(other fns) DiamondLoupeFacet, DiamondProxyFacet, DiamondOwnerFacet, SupportsInterfaceFacet
        assertEq(diamond.interfaces().length, 5); // IERC165, IDiamondCut, IDiamondLoupe, IERC173, EIP5313
        assertTrue(diamond.supportsInterface(type(IERC165).interfaceId));
        assertTrue(diamond.supportsInterface(type(IDiamondCut).interfaceId));
        assertTrue(diamond.supportsInterface(type(IDiamondLoupe).interfaceId));
        assertTrue(diamond.supportsInterface(type(IERC173).interfaceId));
        assertEq(diamond.owner(), owner);
        assertFalse(diamond.owner() == address(0));
    }

    function testDiamondInitialized() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        address payable diamond = payable(address(factory.gogogo(owner)));
        assertTrue(diamond.code.length > 0);

        assertEq(CutDiamond(diamond).owner(), owner);

        address diamondCutFacet = CutDiamond(diamond).facetAddress(DiamondCutFacet.cutSelector.selector);
        assertFalse(diamondCutFacet == address(0));

        vm.expectRevert(Diamond.DiamondAlreadyInitialized.selector);
        Diamond(diamond).initializeDiamond(diamondCutFacet);
    }

    function testFacetCuts() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        CutDiamond diamond = factory.gogogo(owner);
        address diamondCutFacet = diamond.facetAddress(DiamondCutFacet.cutSelector.selector);
        address diamondLoupeFacet = diamond.facetAddress(DiamondLoupeFacet.facets.selector);
        address diamondProxyFacet = diamond.facetAddress(DiamondProxyFacet.setImplementation.selector);
        address diamondOwnerFacet = diamond.facetAddress(DiamondOwnerFacet.owner.selector);
        address supportsInterfaceFacet = diamond.facetAddress(SupportsInterfaceFacet.supportsInterface.selector);
        assertFalse(diamondCutFacet == address(0));
        assertFalse(diamondLoupeFacet == address(0));
        assertFalse(diamondProxyFacet == address(0));
        assertFalse(diamondOwnerFacet == address(0));
        assertFalse(supportsInterfaceFacet == address(0));
        assertFalse(diamondCutFacet == diamondLoupeFacet);
        assertFalse(diamondCutFacet == diamondProxyFacet);
        assertFalse(diamondCutFacet == diamondOwnerFacet);
        assertFalse(diamondCutFacet == supportsInterfaceFacet);
        assertFalse(diamondLoupeFacet == diamondProxyFacet);
        assertFalse(diamondLoupeFacet == diamondOwnerFacet);
        assertFalse(diamondLoupeFacet == supportsInterfaceFacet);
        assertFalse(diamondProxyFacet == diamondOwnerFacet);
        assertFalse(diamondProxyFacet == supportsInterfaceFacet);
        assertFalse(diamondOwnerFacet == supportsInterfaceFacet);
    }

    function testDiamondCutFacetAttached() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        CutDiamond diamond = factory.gogogo(owner);
        address diamondCutFacet = diamond.facetAddress(DiamondCutFacet.cutSelector.selector);
        assertFalse(diamondCutFacet == address(0));

        assertEq(diamond.facetAddress(0xe57e69c6), diamondCutFacet);
        assertEq(diamond.facetAddress(bytes4(keccak256('diamondCut((address,uint8,bytes4[])[])'))), diamondCutFacet);

        // TODO - The Gogogo script needs a refactor for this to work... in test mode,
        //  the DiamondCutFacet is deployed twice between the Diamond constructor and
        //  the actual facet setups so this gets confused...

        // assertEq(diamond.facetAddress(0x1f931c1c), diamondCutFacet);
        // assertEq(
        //     diamond.facetAddress(bytes4(keccak256('diamondCut((address,uint8,bytes4[])[],address,bytes)'))),
        //     diamondCutFacet
        // );
    }

    function testDiamondProxyFacetAttached() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        CutDiamond diamond = factory.gogogo(owner);
        assertEq(diamond.owner(), owner);
        address diamondProxyFacet = diamond.facetAddress(DiamondProxyFacet.implementation.selector);
        assertFalse(diamondProxyFacet == address(0));
        assertEq(diamond.facetAddress(DiamondProxyFacet.implementation.selector), diamondProxyFacet);
        assertEq(diamond.facetAddress(DiamondProxyFacet.setImplementation.selector), diamondProxyFacet);
        assertEq(diamond.owner(), owner);
        vm.prank(owner);
        diamond.deleteSelector(DiamondProxyFacet.setImplementation.selector);
        assertEq(diamond.facetAddress(DiamondProxyFacet.implementation.selector), diamondProxyFacet);
        assertEq(diamond.facetAddress(DiamondProxyFacet.setImplementation.selector), address(0));
    }

    function testImplementationSet() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        CutDiamond diamond = factory.gogogo(owner);
        address implementationFacet = diamond.implementation();
        assertFalse(implementationFacet == address(0));
    }

    // add this to be excluded from coverage report
    function test() public {}
}
