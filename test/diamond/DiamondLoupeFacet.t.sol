// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {DiamondOwnerFacet} from '../../src/diamond/DiamondOwnerFacet.sol';
import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';

contract DiamondLoupeFacetTest is Test {
    MockDiamondLoupeFacet private facet;
    address owner = makeAddr('owner');

    function setUp() public {
        facet = new MockDiamondLoupeFacet();
        facet.setContractOwner(owner);
    }

    // add this to be excluded from coverage report
    function test() public {}

    //  TODO
}

contract MockDiamondLoupeFacet {
    function setContractOwner(address newOwner) public {
        LibContractOwner.setContractOwner(newOwner);
    }

    // add this to be excluded from coverage report
    function test() public {}
}
