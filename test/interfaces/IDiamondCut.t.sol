// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';

contract IDiamondCutTest is Test {
    function setUp() public {}

    function testFacetCutAction() public {
        assertEq(uint(IDiamondCut.FacetCutAction.Add), 0);
        assertEq(uint(IDiamondCut.FacetCutAction.Replace), 1);
        assertEq(uint(IDiamondCut.FacetCutAction.Remove), 2);
    }

    // function testFacetCut() public {
    //      TODO: Structs can't be instantiated from Interfaces yet...
    //     IDiamondCut.FacetCut memory fc = new IDiamondCut.FacetCut();
    //     fc.facetAddress = address(1);
    //     fc.action = IDiamondCut.FacetCutAction.Replace;
    //     fc.functionSelectors = new bytes4[](0x12345678);
    //     assertEq(fc.facetAddress, address(1));
    //     assertEq(fc.action, IDiamondCut.FacetCutAction.Replace);
    //     assertEq(fc.functionSelectors, new bytes4[](0x12345678));
    // }
}
