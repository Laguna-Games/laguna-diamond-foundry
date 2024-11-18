// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {DiamondCutFacet} from '../../src/diamond/DiamondCutFacet.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {DiamondLoupeFacet} from '../../src/diamond/DiamondLoupeFacet.sol';
import {LibDiamond} from '../../src/libraries/LibDiamond.sol';
import {TestDiamondFactory} from './TestDiamondFactory.sol';
import {CutDiamond} from '../../src/diamond/CutDiamond.sol';
import {TestSnapshotFactory} from './TestSnapshotFactory.t.sol';
import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';

contract DiamondCutFacetTest is Test, TestSnapshotFactory {
    MockDiamondCutFacet private facet;
    address owner = makeAddr('owner');

    address mock1;
    address mock2;
    address mock3;
    IDiamondCut.FacetCut cut1;
    IDiamondCut.FacetCut cut2;
    IDiamondCut.FacetCut cut3;

    function setUp() public {
        facet = new MockDiamondCutFacet();
        facet.setContractOwner(owner);
        mock1 = address(new MockFacet());
        mock2 = address(new MockFacet());
        mock3 = address(new MockFacet());
        cut1 = IDiamondCut.FacetCut({
            facetAddress: mock1,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: new bytes4[](1)
        });
        cut1.functionSelectors[0] = MockFacet.foo.selector;

        cut2 = IDiamondCut.FacetCut({
            facetAddress: mock2,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: new bytes4[](1)
        });
        cut2.functionSelectors[0] = MockFacet.bar.selector;

        cut3 = IDiamondCut.FacetCut({
            facetAddress: mock3,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: new bytes4[](1)
        });
        cut3.functionSelectors[0] = MockFacet.bat.selector;
    }

    function testCheckSetup() public {
        assertTrue(mock1.code.length > 0);
        assertTrue(mock2.code.length > 0);
        assertTrue(mock3.code.length > 0);
        assertFalse(mock1 == address(0));
        assertFalse(mock2 == address(0));
        assertFalse(mock3 == address(0));
        assertFalse(mock1 == mock2);
        assertFalse(mock1 == mock3);
        assertFalse(mock2 == mock3);
    }

    function testDiamondCutLongSignature(address fuzzAddress1, bytes memory fuzzBytes1) public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);
        cuts[0] = cut1;
        cuts[1] = cut2;
        cuts[2] = cut3;
        vm.expectEmit(true, true, true, false);
        emit LibDiamond.DiamondCut(cuts, fuzzAddress1, fuzzBytes1);
        vm.prank(owner);
        facet.diamondCut(cuts, fuzzAddress1, fuzzBytes1);
        assertEq(facet.facets().length, 3);
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(facet.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(facet.facetAddress(MockFacet.bat.selector), mock3);
    }

    function testDiamondCutShortSignature() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);
        cuts[0] = cut1;
        cuts[1] = cut2;
        cuts[2] = cut3;
        vm.expectEmit(true, true, true, false);
        emit LibDiamond.DiamondCut(cuts, address(0), '');
        vm.prank(owner);
        facet.diamondCut(cuts);
        assertEq(facet.facets().length, 3);
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(facet.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(facet.facetAddress(MockFacet.bat.selector), mock3);
    }

    function testDiamondCutGuardsOnOwner(address fuzzAddress1) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(fuzzAddress1 != owner);
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = cut1;
        vm.expectRevert(LibContractOwner.CallerIsNotContractOwner.selector);
        vm.prank(fuzzAddress1);
        facet.diamondCut(cuts);
        vm.expectRevert(LibContractOwner.CallerIsNotContractOwner.selector);
        vm.prank(fuzzAddress1);
        facet.diamondCut(cuts, address(0), '');
    }

    function testMultipleAddFails() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = cut1;
        vm.prank(owner);
        facet.diamondCut(cuts, address(0), '');
        cuts[0].facetAddress = mock2;
        vm.expectRevert("LibDiamondCut: Can't add function that already exists");
        vm.prank(owner);
        facet.diamondCut(cuts, address(0), '');
    }

    function testReplace() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = cut1;
        vm.prank(owner);
        facet.diamondCut(cuts, address(0), '');
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        cuts[0].facetAddress = mock2;
        cuts[0].action = IDiamondCut.FacetCutAction.Replace;
        vm.prank(owner);
        facet.diamondCut(cuts, address(0), '');
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock2);
    }

    function testCutSelector() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);
        cuts[0] = cut1;
        cuts[1] = cut2;
        cuts[2] = cut3;
        vm.prank(owner);
        facet.diamondCut(cuts);
        assertEq(facet.facets().length, 3);
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(facet.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(facet.facetAddress(MockFacet.bat.selector), mock3);

        IDiamondCut.FacetCut[] memory negCuts = new IDiamondCut.FacetCut[](1);
        negCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: new bytes4[](1)
        });
        negCuts[0].functionSelectors[0] = MockFacet.foo.selector;

        vm.expectEmit(true, true, true, false);
        emit LibDiamond.DiamondCut(negCuts, address(0), '');
        vm.prank(owner);
        facet.cutSelector(MockFacet.foo.selector);
        assertEq(facet.facets().length, 2);
        assertEq(facet.facetAddress(MockFacet.foo.selector), address(0));
    }

    function testDeleteSelector() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);
        cuts[0] = cut1;
        cuts[1] = cut2;
        cuts[2] = cut3;
        vm.prank(owner);
        facet.diamondCut(cuts);
        assertEq(facet.facets().length, 3);
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(facet.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(facet.facetAddress(MockFacet.bat.selector), mock3);

        vm.prank(owner);
        facet.deleteSelector(MockFacet.bar.selector);
        assertEq(facet.facets().length, 2);
        assertEq(facet.facetAddress(MockFacet.bar.selector), address(0));
    }

    function testCutSelectors() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);
        cuts[0] = cut1;
        cuts[1] = cut2;
        cuts[2] = cut3;
        vm.prank(owner);
        facet.diamondCut(cuts);
        assertEq(facet.facets().length, 3);
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(facet.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(facet.facetAddress(MockFacet.bat.selector), mock3);

        IDiamondCut.FacetCut[] memory negCuts = new IDiamondCut.FacetCut[](1);
        negCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: new bytes4[](2)
        });
        negCuts[0].functionSelectors[0] = MockFacet.foo.selector;
        negCuts[0].functionSelectors[1] = MockFacet.bat.selector;

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = MockFacet.foo.selector;
        selectors[1] = MockFacet.bat.selector;

        vm.expectEmit(true, true, true, false);
        emit LibDiamond.DiamondCut(negCuts, address(0), '');
        vm.prank(owner);
        facet.cutSelectors(selectors);

        assertEq(facet.facets().length, 1);
        assertEq(facet.facetAddress(MockFacet.foo.selector), address(0));
        assertEq(facet.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(facet.facetAddress(MockFacet.bat.selector), address(0));
    }

    function testDeleteSelectors() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);
        cuts[0] = cut1;
        cuts[1] = cut2;
        cuts[2] = cut3;
        vm.prank(owner);
        facet.diamondCut(cuts);
        assertEq(facet.facets().length, 3);
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(facet.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(facet.facetAddress(MockFacet.bat.selector), mock3);

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = MockFacet.bar.selector;
        selectors[1] = MockFacet.bat.selector;

        vm.prank(owner);
        facet.deleteSelectors(selectors);
        assertEq(facet.facets().length, 1);
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(facet.facetAddress(MockFacet.bar.selector), address(0));
        assertEq(facet.facetAddress(MockFacet.bat.selector), address(0));
    }

    function testCutFacet() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);
        cuts[0] = cut1;
        cuts[1] = cut2;
        cuts[2] = cut3;
        vm.prank(owner);
        facet.diamondCut(cuts);
        assertEq(facet.facets().length, 3);
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(facet.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(facet.facetAddress(MockFacet.bat.selector), mock3);

        vm.prank(owner);
        facet.cutFacet(mock3);
        assertEq(facet.facets().length, 2);
        assertEq(facet.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(facet.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(facet.facetAddress(MockFacet.bat.selector), address(0));
    }

    function testIntegratedDiamond() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        CutDiamond diamond = factory.gogogo(owner);

        uint256 count = diamond.facets().length;
        assertTrue(count > 0);

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);
        cuts[0] = cut1;
        cuts[1] = cut2;
        cuts[2] = cut3;

        vm.expectEmit(true, true, true, false);
        emit LibDiamond.DiamondCut(cuts, address(0), '');
        vm.prank(owner);
        diamond.diamondCut(cuts);
        assertEq(diamond.facets().length, count + 3);
        assertEq(diamond.facetAddress(MockFacet.foo.selector), mock1);
        assertEq(diamond.facetAddress(MockFacet.bar.selector), mock2);
        assertEq(diamond.facetAddress(MockFacet.bat.selector), mock3);

        IDiamondCut.FacetCut[] memory negCuts = new IDiamondCut.FacetCut[](1);
        negCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: new bytes4[](1)
        });
        negCuts[0].functionSelectors[0] = MockFacet.foo.selector;

        vm.expectEmit(true, true, true, false);
        emit LibDiamond.DiamondCut(negCuts, address(0), '');
        vm.prank(owner);
        diamond.cutSelector(MockFacet.foo.selector);
        assertEq(diamond.facets().length, count + 2);
        assertEq(diamond.facetAddress(MockFacet.foo.selector), address(0));
    }
}

contract MockDiamondCutFacet is DiamondCutFacet, DiamondLoupeFacet {
    function setContractOwner(address newOwner) public {
        LibContractOwner.setContractOwner(newOwner);
    }
}

//  This exists so a target "facet" has on-chain bytecode
contract MockFacet {
    function foo() external pure returns (uint8) {
        return 5;
    }

    function bar() external pure returns (bool) {
        return true;
    }

    function bat() external pure returns (string memory) {
        return '^^$^^';
    }

    // add this to be excluded from coverage report
    function test() public {}
}
