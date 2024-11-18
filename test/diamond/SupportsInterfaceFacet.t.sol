// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {SupportsInterfaceFacet} from '../../src/diamond/SupportsInterfaceFacet.sol';
import {LibSupportsInterface} from '../../src/libraries/LibSupportsInterface.sol';
import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';

contract DiamondProxyFacetTest is Test {
    MockSupportsInterfaceFacet private facet;
    address owner = makeAddr('owner');

    function setUp() public {
        facet = new MockSupportsInterfaceFacet();
        facet.setContractOwner(owner);
    }

    function testSupportsInterface(bytes4 fuzzSelector) public {
        vm.assume(fuzzSelector != bytes4(0));
        assertFalse(facet.supportsInterface(fuzzSelector));

        uint count = facet.interfaceCount();
        assertEq(count, 0);

        vm.prank(owner);
        facet.setSupportsInterface(fuzzSelector, true);

        assertTrue(facet.supportsInterface(fuzzSelector));
        assertFalse(count == facet.interfaceCount(), 'count did not change');

        count = facet.interfaceCount();
        assertEq(count, 1);

        vm.prank(owner);
        facet.setSupportsInterface(fuzzSelector, false);
    }

    function testSupportsInterfaceDoubleAdd(bytes4 fuzzSelector1, bytes4 fuzzSelector2) public {
        vm.assume(fuzzSelector1 != bytes4(0));
        vm.assume(fuzzSelector2 != bytes4(0));
        vm.assume(fuzzSelector1 != fuzzSelector2);
        assertFalse(facet.supportsInterface(fuzzSelector1));
        assertFalse(facet.supportsInterface(fuzzSelector2));

        uint count = facet.interfaceCount();
        assertEq(count, 0);

        vm.startPrank(owner);
        facet.setSupportsInterface(fuzzSelector1, true);

        //  Adding interface increments to 1
        assertTrue(facet.supportsInterface(fuzzSelector1));
        assertEq(facet.interfaceCount(), 1);

        //  Adding the same one doesn't increment again
        facet.setSupportsInterface(fuzzSelector1, true);
        assertTrue(facet.supportsInterface(fuzzSelector1));
        assertEq(facet.interfaceCount(), 1);

        //  Removing doesn't decrement (for now)
        facet.setSupportsInterface(fuzzSelector1, false);
        assertFalse(facet.supportsInterface(fuzzSelector1));
        assertEq(facet.interfaceCount(), 1);

        //  Adding a new interface increments to 2
        facet.setSupportsInterface(fuzzSelector2, true);
        assertEq(facet.interfaceCount(), 2);

        //  Adding the same one doesn't increment again
        facet.setSupportsInterface(fuzzSelector2, true);
        assertEq(facet.interfaceCount(), 2);

        //  Removing doesn't decrement (for now)
        facet.setSupportsInterface(fuzzSelector2, false);
        assertFalse(facet.supportsInterface(fuzzSelector2));
        assertEq(facet.interfaceCount(), 2);

        vm.stopPrank();
    }

    function testSetSupportsInterfaceGuardsOnOwner(address fuzzAddress1, bytes4 fuzzSelector) public {
        vm.assume(fuzzAddress1 != owner);
        vm.assume(fuzzSelector != bytes4(0));
        vm.expectRevert(LibContractOwner.CallerIsNotContractOwner.selector);
        vm.prank(address(fuzzAddress1));
        facet.setSupportsInterface(fuzzSelector, true);
    }

    function testInterfaces(bytes4 fuzzSelector1, bytes4 fuzzSelector2) public {
        vm.assume(fuzzSelector1 != bytes4(0));
        vm.assume(fuzzSelector2 != bytes4(0));
        vm.assume(fuzzSelector1 != fuzzSelector2);
        assertEq(facet.interfaces().length, 0);
        vm.startPrank(owner);
        facet.setSupportsInterface(fuzzSelector1, true);
        facet.setSupportsInterface(fuzzSelector2, true);
        LibSupportsInterface.KnownInterface[] memory interfaces = SupportsInterfaceFacet(facet).interfaces();
        assertEq(interfaces.length, 2);
        assertEq(facet.interfaces()[0].selector, fuzzSelector1);
        assertEq(facet.interfaces()[0].supported, true);
        assertEq(facet.interfaces()[1].selector, fuzzSelector2);
        assertEq(facet.interfaces()[1].supported, true);
        vm.stopPrank();
    }

    function testSetSupporsInterfaces(bytes4 fuzzSelector1, bytes4 fuzzSelector2, bytes4 fuzzSelector3) public {
        vm.assume(fuzzSelector1 != bytes4(0));
        vm.assume(fuzzSelector2 != bytes4(0));
        vm.assume(fuzzSelector3 != bytes4(0));
        vm.assume(fuzzSelector1 != fuzzSelector2);
        vm.assume(fuzzSelector1 != fuzzSelector3);
        vm.assume(fuzzSelector2 != fuzzSelector3);
        assertFalse(facet.supportsInterface(fuzzSelector1));
        assertFalse(facet.supportsInterface(fuzzSelector2));
        assertFalse(facet.supportsInterface(fuzzSelector3));

        assertEq(facet.interfaces().length, 0);

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = fuzzSelector1;
        selectors[1] = fuzzSelector2;
        selectors[2] = fuzzSelector3;

        vm.prank(owner);
        facet.setSupportsInterfaces(selectors, true);

        assertTrue(facet.supportsInterface(fuzzSelector1));
        assertTrue(facet.supportsInterface(fuzzSelector2));
        assertTrue(facet.supportsInterface(fuzzSelector3));
        assertEq(facet.interfaces().length, 3);
    }

    function testSetSupporsInterfacesGuardsOnOwner(
        bytes4 fuzzSelector1,
        bytes4 fuzzSelector2,
        address fuzzAddress1
    ) public {
        vm.assume(fuzzSelector1 != bytes4(0));
        vm.assume(fuzzSelector2 != bytes4(0));
        vm.assume(fuzzSelector1 != fuzzSelector2);
        assertFalse(facet.supportsInterface(fuzzSelector1));
        assertFalse(facet.supportsInterface(fuzzSelector2));

        vm.assume(fuzzAddress1 != owner);
        vm.assume(fuzzAddress1 != address(0));

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = fuzzSelector1;
        selectors[1] = fuzzSelector2;

        vm.expectRevert(LibContractOwner.CallerIsNotContractOwner.selector);
        vm.prank(fuzzAddress1);
        facet.setSupportsInterfaces(selectors, true);

        assertFalse(facet.supportsInterface(fuzzSelector1));
        assertFalse(facet.supportsInterface(fuzzSelector2));
        assertEq(facet.interfaces().length, 0);
    }
}

contract MockSupportsInterfaceFacet is SupportsInterfaceFacet {
    function setContractOwner(address newOwner) public {
        LibContractOwner.setContractOwner(newOwner);
    }

    function interfaceCount() public view returns (uint) {
        LibSupportsInterface.SupportsInterfaceStorage storage s = LibSupportsInterface.supportsInterfaceStorage();
        return s.interfaces.length;
    }
}
