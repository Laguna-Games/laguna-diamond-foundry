// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {DiamondProxyFacet} from '../../src/diamond/DiamondProxyFacet.sol';
import {LibProxyImplementation} from '../../src/libraries/LibProxyImplementation.sol';
import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';

contract DiamondProxyFacetTest is Test {
    MockDiamondProxyFacet private facet;
    address owner = makeAddr('owner');

    function setUp() public {
        facet = new MockDiamondProxyFacet();
        facet.setContractOwner(owner);
    }

    function testImplementation(address fuzzAddress1) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.expectEmit(true, true, true, false);
        emit LibProxyImplementation.Upgraded(fuzzAddress1);
        assertEq(facet.implementation(), address(0));
        vm.prank(address(owner));
        facet.setImplementation(fuzzAddress1);
        assertEq(facet.implementation(), fuzzAddress1);
    }

    function testImplementationGuardsOnOwner(address fuzzAddress1) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(fuzzAddress1 != owner);
        vm.expectRevert(LibContractOwner.CallerIsNotContractOwner.selector);
        vm.prank(address(fuzzAddress1));
        facet.setImplementation(makeAddr('testImplementation'));
    }
}

contract MockDiamondProxyFacet is DiamondProxyFacet {
    function setContractOwner(address newOwner) public {
        LibContractOwner.setContractOwner(newOwner);
    }

    // add this to be excluded from coverage report
    function test() public {}
}
