// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {DiamondOwnerFacet} from '../../src/diamond/DiamondOwnerFacet.sol';
import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';

contract DiamondOwnerFacetTest is Test {
    DiamondOwnerFacet private facet;

    function setUp() public {
        facet = new DiamondOwnerFacet();
    }

    function testTransferOwnership(address fuzzAddress1, address fuzzAddress2) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(facet.owner() == address(0));

        vm.prank(address(0));
        facet.transferOwnership(fuzzAddress1);
        assertEq(facet.owner(), fuzzAddress1);

        vm.assume(fuzzAddress2 != fuzzAddress1);
        vm.assume(fuzzAddress2 != address(0));

        vm.prank(fuzzAddress1);
        facet.transferOwnership(fuzzAddress2);
        assertEq(facet.owner(), fuzzAddress2);
    }

    function testTransferOwnershipEvents(address fuzzAddress1) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(facet.owner() == address(0));

        vm.expectEmit(true, true, true, false);
        emit LibContractOwner.OwnershipTransferred(address(0), fuzzAddress1);

        vm.expectEmit(true, true, true, false);
        emit LibContractOwner.AdminChanged(address(0), fuzzAddress1);

        vm.prank(address(0));
        facet.transferOwnership(fuzzAddress1);
        assertEq(facet.owner(), fuzzAddress1);
    }

    function testImplementationGuardsOnOwner(address fuzzAddress1) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.expectRevert(LibContractOwner.CallerIsNotContractOwner.selector);
        vm.prank(address(fuzzAddress1));
        facet.transferOwnership(makeAddr('testImplementation'));
    }
}
